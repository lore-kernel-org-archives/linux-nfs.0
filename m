From: David Kewley <dk1@cns.caltech.edu>
Subject: subtree_check questions
Date: Tue, 7 May 2002 01:12:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020507081225.C2CF9402C@synapse.cns.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bbbtest.caltech.edu ([131.215.31.143] helo=synapse.cns.caltech.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17505N-0001EM-00
	for <nfs@lists.sourceforge.net>; Tue, 07 May 2002 01:12:37 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello all,

I'm not on the list, so please include me in any replies.

A bit of background: I'm a sysadmin at Caltech in Pasadena, CA, USA.  I'm 
about to put together a new NFS v2/v3 server, and am mining the web for ideas 
for how to make my NFS installation reasonably secure.  I'm going to use Red 
Hat Linux 7.2 or 7.3 on a Dell machine.  Up to now I've been testing with 
kernel 2.4.9-13, nfs-utils nfs-utils-0.3.1-13.7.2.1 and (for convenience) 
have been using the same machine as nfs server and nfs client.  I'll probably 
shift soon to RH 7.3 with whatever kernel and nfs-utils it uses, and will 
test between machines across the network.

I have two questions / issues: 1) regarding subtree_check and a possible NFS 
exploit, and 2) a possible bug in the handling of subtree_check.

Regarding (1) above, I'm responding to something Neil Brown posted to the 
nfsv4-wg mailing list on 2002.03.27:

http://playground.sun.com/pub/nfsv4/nfsv4-wg-archive/2002/0132.html

In brief, Neil suggests (apologies if I paraphrase inaccurately) that if a 
subdir is exported rather than a whole filesystem (and I suppose if 
no_subtree_check is chosen), that you can get a filehandle for the filesystem 
root directory by walking up the .. directories.  I found this not to be true 
in my test setup.

For a testing tool, I snagged an nfs client by Jefferson Ogata, from:

http://www.antibozo.net/ogata/webtools/nfs/nfs.html

I also tried nfsshell, which Neil mentioned in his post, but I found that 
Ogata's tool seemed to do what I needed better than nfsshell.  I also got a 
program called nfsbug while I was at it.  The source for all 3 programs is 
pretty old, and I had to make some adjustments to get them to compile under 
Red Hat 7.2.  Let me know if you need URL's for nfsshell or nfsbug.  Also if 
you like, I can email attachments containing the source for all three 
programs, with the modifications I made to get them to compile.

Once I got the Ogata nfs client working, I tried to do what Neil suggested in 
his post: walking up from an exported subdir to the filesystem root via .. 
links.  Lo and behold, I could not get a filehandle for /<exportroot>/.. even 
when the filesystem is exported with no_subtree_check.

So I wanted to check with you folks: have I totally screwed up?  Are any of 
you able to get a valid filehandle for /<exportroot>/.. in a recent Linux 
install?  How?  If not, then I guess the current NFS is resistant to this 
exploit, despite Neil's post.

Neil cautioned in his post that "NFS is for exporting filesystems, not 
filetrees."  If the exploit he described is (no longer) available, then I 
feel happier about exporting subdirectories, which I may want to do in order 
to restrict access to home directories by client IP, while still having home 
directories share a filesystem on the fileserver.

Are there any other strong reasons to prefer exporting whole filesystems 
instead of exporting subdirectories?

All the foregoing still leaves the question: is it a bad idea to use 
no_subtree_check if I export a subdirectory rather than a whole filesystem?  
(The exports(5) man page seem to suggest no_subtree_check is best used only 
with exported filesystems.)  If it is a bad idea, what would be the 
consequences if I did so?  If it's an OK idea, does the use of 
no_subtree_check have any advantages, e.g. a performance boost since the 
server doesn't do subtree checks?

------------

On to issue (2) above: a possible bug, or else a misunderstanding on my part 
from reading the exports(5) man page.

The exports(5) man page says, "subtree checking is also used to make sure 
that files inside directories to which only root has access can only be 
accessed if the filesystem is exported with no_root_squash (see below), even 
the file itself allows more general access."  This is rather hard to parse, 
but I'm hoping I understand it. ;)

Here's how I tested this assertion (or what I understand it to mean, at any 
rate).  I made a directory /home/nfstest owned by root:root, permissions 
0700.  I then made a directory /home/nfstest/testdir owned by kewley:kewley, 
permissions 0775.

If /etc/exports is:

/home/nfstest   *(rw,no_subtree_check)

I can connect to the nfs server with Ogata's nfs client, but can't get a 
directory listing of the mounted root directory.  Presumably that's because 
/home/nfstest has root-only permissions, so can't be accessed by any uid on 
the client.

On the other hand, when /etc/exports is:

/home/nfstest/testdir   *(rw,subtree_check)

I can connect to the server and get a directory listing and modify files in 
/home/nfstest/testdir, even though I have root_squash and subtree_check 
(confirmed in /var/lib/nfs/etab), and /home/nfstest is root:root 0700.  It 
seems like this is undesired, insecure behavior by the server, and violates 
the exports(5) description of subtree_check.  Have I found a bug, or am I 
doing something wrong?

I guess these are partly user-support questions, and partly questions for 
active developers.  I realize this is a developers' list, and I very much 
appreciate any feedback you folks might have, even if it's "ask someone 
else", in which case I'd appreciate a pointer. :)

Thanks very much,
David Kewley

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

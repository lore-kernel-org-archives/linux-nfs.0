From: Matthew Mitchell <matthew@geodev.com>
Subject: Re: More about nfsd/lockd hang in 2.4.20+NFS_ALL
Date: Fri, 13 Jun 2003 11:48:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EEA006C.2080203@geodev.com>
References: <3EE9D5BB.6040600@geodev.com>	<shsd6hikmgi.fsf@charged.uio.no>	<3EE9F97C.9070006@geodev.com> <16105.64592.996167.136600@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[48BLxVzKm0TPK8X980g34dRHvfiWfROM])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QrnD-0005aj-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 09:52:47 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16105.64592.996167.136600@charged.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:
>>>>>>" " == Matthew Mitchell <matthew@geodev.com> writes:
> 
> 
>      > rpc.statd in this case is running as an unprivileged user, yes.
>      > So lockd will not allow a local statd to talk to it unless it
>      > is running on a privileged port?  That seems to be what is
>      > going on in the conditional.  Next question is -- why?
> 
> For obvious reasons, you don't want any Tom, Dick or Harry to be able
> to tell the kernel that it should try to recover locking state from a
> given server.

Right, it has to come from localhost on a privileged port.  I 
understand.  But how could it ever work if it's not working in this 
case?  Maybe this is a red herring.

According to rpcinfo on this server, which is also the client, port 
32769 is "sgi_fam".  What is that?  status is 32768.  Perhaps it's 
rejecting it with good cause.

>      > Even assuming there is a good reason, why might it cause the
>      > whole nfs system to hang?
> 
> My guess (since you are not supplying a tcpdump) is that the server is
> down. That's when it is supposed to happen, anyway...

Hmm.  So the messages from lockd could just be a symptom of the problem 
(nfsd locking up), you think.  I first noticed the problem when a remote 
user logged into the server, and the home directory (exported by the 
server) got remounted by the automounter on a local path.

But just now I tried manually mounting the home directories on another 
local path, and it seems to work fine.

Perhaps it involves the automounter somehow?  I did notice that the 
output of mount looked funny when I was trying to see if the volume had 
been remounted.  It was something like

fenris:/export/users on /home/users type nfs (rw,bind)

instead of

fenris:/export/users on /home/users type nfs (rw,addr=127.0.0.1)

I can try to reproduce the problem with autofs, but these are user home 
directories,  and they might get annoyed. :)

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

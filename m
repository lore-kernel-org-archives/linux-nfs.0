From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: "nfsd Security: //u bad export" is triggered by IRIX clients
Date: 22 Jul 2003 16:40:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1058884809.7602.25.camel@ikarus>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eyJI-00029L-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 07:40:13 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id DC2D558EDE
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 16:40:09 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 28618-01-10 for <nfs@lists.sourceforge.net>;
 Tue, 22 Jul 2003 16:40:08 +0200 (MEST)
Received: from ikarus (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id A1CB858ED6
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 16:40:08 +0200 (MEST)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

I made a post about this issue on the 7th of July, back then I didn't
know what was causing those error messages on my RedHat 7.3 NFS server
with kernel 2.4.18-27.7.xsmp and nfs-utils 1.0.3.

Today, a user reported a problem he has with his home directory on an
IRIX64 6.5 machine. His home used to be mounted from an SGI server,
since a couple of days, it's been moved to the Linux server. As of then,
the following problem occurs:

# cd /home/user
# pwd
/home/user
# cd work
# pwd
This command will return sometimes a), sometimes b):
a) /work
b) Cannot determine current directory
# echo $PWD
/home/user/work
echo $SHELL
/bin/tcsh (btw, it makes a difference here if I use tcsh or bash, under
bash PWD returns the correct path)

For each 'pwd' issued, where it would return b), I see the error message
"nfsd Security: //u bad export" on the console of the server. The
corresponding export entry on the server is:
/export/home/h1/u/user @user(rw,sync)

The permissions for /export/home/h1/u and /export/home/h1/u/user are
0755, the owner of /export/home/h1/u is root:root, the owner of
/export/home/h1/u/user is user:105.

Any ideas how this issue can be fixed? TIA.

Regards,

    Marc





-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

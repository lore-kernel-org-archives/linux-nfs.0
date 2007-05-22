From: Neil Brown <neilb@suse.de>
Subject: Re: how to execute a script from NFS mount (which
	disconnected)?
Date: Tue, 22 May 2007 22:42:22 +1000
Message-ID: <18002.58670.174770.248425@notabene.brown>
References: <4652C7ED.9010309@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqThB-0001ge-JS
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:42:33 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqThE-0007wX-8s
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:42:36 -0700
In-Reply-To: message from Tomasz Chmielewski on Tuesday May 22
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday May 22, mangoo@wpkg.org wrote:
> This question may sound silly, but I didn't find a proper solution to it.
> 
> I have a script on a NFS share. The purpose of this script is to do some 
> network reconfiguration for Xen.
> 
> Unfortunately, it fails to execute somewhere in the middle.
> 
> Basically, the script brings the network interface down, does a bit of 
> reconfiguring, and then, the interface is brought up.
...
> 
> 
> Unfortunately, when I execute it locally, the script freezes somewhere 
> about step 2 or 3. Which I could perfectly understand - as the system 
> can't read it.

Not really.  bash reads the whole script before executing it - or at
least it did in my limited tests.  strace would confirm.

My guess is that your $PATH includes a directory that is on the NFS
mounted volume - so when bash looks for e.g. 'sleep', it looks on the
NFS mounted volume and hangs.
Try running the script with "strace -f".  It might be noisy, but it
will show you what is blocking.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

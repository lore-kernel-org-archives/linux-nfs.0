From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: of rmtab and 'Invalid argument' and permission denied
Date: Sun, 9 Mar 2003 09:48:16 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15978.29488.872457.834848@notabene.cse.unsw.edu.au>
References: <20030308192021.GB747@gallifrey>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18rn7t-0005d0-00
	for <nfs@lists.sourceforge.net>; Sat, 08 Mar 2003 14:49:09 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <gilbertd@treblig.org>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 9 Mar 2003 09:48:25 +1100
To: "Dr. David Alan Gilbert" <gilbertd@treblig.org>
In-Reply-To: message from Dr. David Alan Gilbert on Saturday March 8
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

On Saturday March 8, gilbertd@treblig.org wrote:
> Hi,
>   I have a problem with an NFS server running SuSE 8.1 and serving
> to a mix of different systems; the server runs the kernel server.
> 
> Sometimes the client will get a permission denied on attempting to mount
> from the server even though it managed it a few hours earlier with no
> change to config of the server.
> 
> Restarting the nfs server gives a line of the form:
> 
> clienthostname: Invalid argument
> 

What does your /etc/exports file look like?  Does it have both host
names and IP addresses?  
Do you export both a directory and an ancestor of that directory on
the same filesystem?

Both of these can cause this sort of problem.

What version of nfs-utils is in SuSE 8.1?

 showmount -v

will tell you.

NeilBrown

> Going into /var/lib/nfs/rmtab and removing the entries for the client
> and then restarting cause both the Invalid argument error and the
> mounting problems to disappear.
> 
> I'm not sure but one observation is that for the clients which have the
> problem the rmtab contains two entries for the same file system - e.g.
> 
> clienthostname:/mountpoint:0x00000005
> clienthostname:/mountpoint/a/sub/directory:0x00000002
> 
> I haven't been able to replicate the problem on a Debian (sid) box that I
> happen to have here (even with the SuSE mountd binaries).
> 
> So questions:
>   1) Has this been seen before - what are the known causes/cures.
> 	2) What exactly reads rmtab (is it mountd?) - are there any easy ways
> 	to track the problem?
> 
> Thanks in advance,
> 
> Dave
>  ---------------- Have a happy GNU millennium! ----------------------   
> / Dr. David Alan Gilbert    | Running GNU/Linux on Alpha,68K| Happy  \ 
> \ gro.gilbert @ treblig.org | MIPS,x86,ARM,SPARC,PPC & HPPA | In Hex /
>  \ _________________________|_____ http://www.treblig.org   |_______/
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger
> for complex code. Debugging C/C++ programs can leave you feeling lost and
> disoriented. TotalView can help you find your way. Available on major UNIX
> and Linux platforms. Try it free. www.etnus.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

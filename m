From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Sun, 16 Nov 2003 10:54:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB79DAF.8E483BD5@psu.edu>
References: <3FB27670.4C878A84@psu.edu>
		<shssmkttk34.fsf@charged.uio.no>
		<3FB29D43.A618973D@psu.edu>
		<16306.41898.291062.36209@charged.uio.no>
		<3FB2A738.3F2C90B8@psu.edu>
		<16306.49310.195265.145519@charged.uio.no>
		<3FB2DC60.FA7D3E08@psu.edu>
		<16306.59249.857512.354675@charged.uio.no>
		<3FB3924B.7450E9F7@psu.edu>
		<3FB3FDE8.47E819FF@psu.edu>
		<16308.8254.89284.377113@charged.uio.no>
		<3FB520E4.133AF7DB@psu.edu> <16309.17670.931812.401791@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ALPFU-0007hj-00
	for <nfs@lists.sourceforge.net>; Sun, 16 Nov 2003 07:55:40 -0800
Received: from vpn-19-8.aset.psu.edu ([146.186.19.8] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ALPEp-00010O-IT
	for nfs@lists.sourceforge.net; Sun, 16 Nov 2003 07:54:59 -0800
To: trond.myklebust@fys.uio.no
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
> 
> >>>>> " " == Jason Holmes <jholmes@psu.edu> writes:
> 
>      > Files should be up there (http://magicbus.cac.psu.edu/nfs).  I
>      > do have to admit that something odd is going on - 2.4.22 still
>      > is faster than 2.6.0-test9-bk17 and test9-bk17 is still showing
>      > the large amount of commits, but both of them are running
>      > faster than they did before on the sync mounts and I'm not sure
>      > what I might have changed to cause this.
> 
> Hmm... It looks like you are doing a succession of 4k commits. I'll
> bet the read() code is involved in this...
> 
> Could you try the following patch and see if it improves things?

That made a huge difference:

Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 714     0% 0       0% 110     0% 204     0% 0       0% 
read       write      create     mkdir      symlink    mknod      
873     0% 178571 92% 24      0% 0       0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 0       0% 
fsstat     fsinfo     pathconf   commit     
0       0% 3       0% 0       0% 13175   6%

Client rpc stats:
calls      retrans    authrefrsh
193716     13         0 

It also cut the job time in about half.  I put a level9 log of it up
with the other ones.  I'll have to rerun the 2.4 vs. this, but I think
that this change makes the 2.6 client faster than the 2.4 for this case.

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF. Net email is sponsored by: GoToMyPC
GoToMyPC is the fast, easy and secure way to access your computer from
any Web browser or wireless device. Click here to Try it Free!
https://www.gotomypc.com/tr/OSDN/AW/Q4_2003/t/g22lp?Target=mm/g22lp.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

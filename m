From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: .x files for NFS v3
Date: Tue, 3 Sep 2002 12:41:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15732.8544.471074.44155@notabene.cse.unsw.edu.au>
References: <3D7363A9.4090304@linkvest.com>
	<15732.7852.166069.553496@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17m3dW-0004g7-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Sep 2002 19:41:50 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <Jean-Eric.Cuendet@linkvest.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 3 Sep 2002 12:41:37 +1000
To: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>,
    nfs@lists.sourceforge.net
In-Reply-To: message from Neil Brown on Tuesday September 3
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

On Tuesday September 3, neilb@cse.unsw.edu.au wrote:
> On Monday September 2, Jean-Eric.Cuendet@linkvest.com wrote:
> > Hi,
> > where should I find .x files for rpcgen for nfsv3?
> > Thanks.
> > -jec
> > 
> 
> RFC1813 has it, though it is pretty spread out.
> 
> If you have solaris around, then
>   /usr/include/rpcsvc/nfs_prot.x

Better still, ask google for "nfs3_prot.x"

e.g.

http://www.fs.net/cvs/sfsnet/svc/Attic/nfs3_prot.x?cvsroot=CFS-CVS&hideattic=0

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

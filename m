From: Brett Jon Grandbois <brettg@sgi.com>
Subject: rdma mount support
Date: Mon, 30 Oct 2006 10:58:51 +1100
Message-ID: <4545403B.8050500@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

Are there any plans on the horizon for including NFS/RDMA support in
nfs-utils?  We're using the NFS/RDMA ONC Transport but that currently
requires the use of a separate nfsrdmamount binary and we'd eventually
like to just call standard mount(8).  Are there any plans for adding
RDMA support in mount.nfs?  Or maybe adding a whole separate
mount.nfsrdma?  There are a few ways to go with this and we'd like to
find out if there's a direction everyone is leaning towards so we don't
end up taking the wrong one.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

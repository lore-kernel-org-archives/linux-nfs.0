From: Neil Brown <neilb@suse.de>
Subject: Re: File has different contents on different clients
Date: Mon, 21 Aug 2006 11:54:13 +1000
Message-ID: <17641.4677.495077.201990@cse.unsw.edu.au>
References: <f3177b9e0608201455w5930d488qe1200982a5602a39@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
To: "Chris Worley" <worleys@gmail.com>
In-Reply-To: message from Chris Worley on Sunday August 20
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

On Sunday August 20, worleys@gmail.com wrote:
> I'm using NFS on  a cluster, and one file seems to keep getting
> different contents on different NFS clients, while having the proper
> attributes on all clients:
> 
....
> 
> If I "touch" the file... all clients get back in sync.  This is the
> second time it's happend to the same file, but different NFS clients
> got out of sync.
> 
> We're running a 2.6.9-22 kernel w/ RHEL4U2.
> 
> Any ideas?

My guess is that the file is getting changed multiple times within one
second, and as the mtime on many filesystems has a resolution of one
second, NFS does not notice subsequent changes.

Maybe you could try '-o noac', but that might hurt your performance.
Maybe you could try a filesystem with hi-res timestamps - I think xfs
has this. 

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

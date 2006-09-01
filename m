From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 019 of 19] knfsd: Register all RPC programs with
	portmapper by default
Date: Fri, 1 Sep 2006 12:08:14 -0400
Message-ID: <76bd70e30609010908n47eb356ob121109961f8221c@mail.gmail.com>
References: <20060901141639.27206.patches@notabene>
	<1060901043948.27677@suse.de>
	<76bd70e30609010831m9e80cfav514d60718d35e7d5@mail.gmail.com>
	<20060901155407.GC29574@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJBZ4-0008Ot-Si
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:08:18 -0700
Received: from wr-out-0506.google.com ([64.233.184.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GJBZ5-0002wB-C1
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:08:19 -0700
Received: by wr-out-0506.google.com with SMTP id 57so396590wri
	for <nfs@lists.sourceforge.net>; Fri, 01 Sep 2006 09:08:15 -0700 (PDT)
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20060901155407.GC29574@suse.de>
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

On 9/1/06, Olaf Kirch <okir@suse.de> wrote:
> On Fri, Sep 01, 2006 at 11:31:25AM -0400, Chuck Lever wrote:
> > I don't like this.  The idea that multiple RPC services are listening
> > on the same port is a total hack.  What other service might use this
> > besides NFSACL?
>
> Why do you consider this a hack? I have always felt that librpc requiring
> you to open separate ports for every program you register was a poor
> design. The RPC header contains the program number, and the RPC code
> is fully capable of demuxing incoming requests. So I do not think it is
> a hack at all.
>
> And yes, Solaris NFSACL resides on 2049 too.

I meant "Does Solaris advertise NFSACL on 2049 via the portmapper?"

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

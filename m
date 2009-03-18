From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Option noac not working correctly?
Date: Wed, 18 Mar 2009 17:34:38 -0400
Message-ID: <1237412078.8714.21.camel@heimdal.trondhjem.org>
References: <49C106DD.2080008@bull.net>
	<1237389003.7275.9.camel@heimdal.trondhjem.org>
	<49C12461.8040001@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49C12461.8040001@bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-03-18 at 17:42 +0100, Diego Moreno wrote:
> Thanks for your quick reply Trond. I've seen the only way to pass my 
> test is using (for kernel 2.6.29-rc8): -olookupcache=positive,noac. If I 
> use -olookupcache=positive or -olookupcache=all or 
> -olookupcache=all,noac my test doesn't pass.

Sorry. You're right... The -olookupcache option only affects lookup of
new files (and I should have said "-olookupcache=positive" or
"-olookupcache=none").
In this test case you are, however doing an 'ls', not a lookup. The
resulting opendir() call will always check if the directory has changed
or not on the NFS server (irrespective of whether or not you use
'noac'). The decision on whether or not to rely on the cached readdir
data then depends entirely on whether or not the server returns a new
value for the NFSv4 change_attribute or the mtime.

The problem therefore is, as I indicated earlier, that the server is
telling the client that nothing changed because it has too poor mtime
resolution...

> BTW, is there any way of passing this test for a kernel like 2.6.27 
> (there is no lookupcache mount option). In kernels like 2.6.19 or 2.6.20 
> I think I passed my test just using noac option. These kernels where the 
> first kernels with the patch (commit 
> b0b539739fe9b7d75002412a787cfdf4efddbc33) treating the special case of 
> nfsi->attrtimeo==0. That means 'noac' or/and actimeo=0 mount options.

'noac' cannot fix this problem.

Cheers
  Trond

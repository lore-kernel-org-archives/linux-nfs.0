Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: Re: nfs-utils-1.2.0 released.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4A254DD1.5060507@RedHat.com>
References: <4A254DD1.5060507@RedHat.com>
Date: Tue, 02 Jun 2009 13:45:00 -0400
Message-Id: <1243964700.4868.130.camel@heimdal.trondhjem.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-02 at 12:05 -0400, Steve Dickson wrote:
> The main reason for this release was the updated
> RPC licenses that were worked out with Sun Microsystems
> 
> A while back it was notice that some of the copyrights
> in nfs-utils were a bit GPL incompatible. So working with
> Sun all the RPC licenses were replaced with BSD licenses
> which are a bit more GPL compatible.
> 
> Note: all of the licenses in both rpcbind and libtirpc have
> also been updated. 
> 
> steved.
> 
> The tarball can be found at:
> 
>   http://www.kernel.org/pub/linux/utils/nfs/
>   http://sourceforge.net/projects/nfs
> 
> The git tree is at:
>    git://linux-nfs.org/nfs-utils
> 
> The change log:
> 
> commit 6b7ad21f8162ec85766fd1369ea13ab432e287f8
> Author: Tom spot Callaway <tcallawa@redhat.com>
> Date:   Tue Jun 2 10:43:05 2009 -0400
> 
>     Replace the Sun RPC license with the BSD license,
>     with the explicit permission of Sun Microsystems
>     
>     Signed-off-by: Tom "spot" Callaway <tcallawa@redhat.com>
>     Signed-off-by: Steve Dickson <steved@redhat.com>

Wow... That is good news, but it would have been nice to have seen a
signed-off-by from someone at Sun on this change, just for documentation
purposes...

Cheers
  Trond

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

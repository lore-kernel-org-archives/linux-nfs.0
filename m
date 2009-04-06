From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/5] nfs-utils: make getnameinfo() required for
	--enable-gss
Date: Mon, 6 Apr 2009 11:05:51 -0400
Message-ID: <3D5F57BE-2706-41BA-878F-057C4C65F792@oracle.com>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
	<1238938983-7347-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1238938983-7347-2-git-send-email-jlayton@redhat.com>
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

On Apr 5, 2009, at 9:42 AM, Jeff Layton wrote:
> Systems that are so old that they don't have getnameinfo() in glibc  
> are
> probably also running kernels that are so old that they don't support
> gssapi upcalls anyway.
>
> Make --enable-gss dependent on the presence of the getnameinfo()
> function.  This allows us to reduce some conditional compilation.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> configure.ac |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/configure.ac b/configure.ac
> index e34b7e2..00aee35 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -207,6 +207,8 @@ if test "$enable_nfsv4" = yes; then
>   dnl but we need to make sure we get the right version
>   if test "$enable_gss" = yes; then
>     AC_RPCSEC_VERSION
> +    AC_CHECK_FUNC([getnameinfo], ,
> +		  [AC_MSG_ERROR([Function 'getnameinfo' not found.])])
>   fi
> fi

This check is only done when enable_nfsv4 is set.  Probably a better  
place for this is in the enable_gss test that is always done, a few  
paragraphs lower.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

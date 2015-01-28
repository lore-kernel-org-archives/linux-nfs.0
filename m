Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756625AbbA2BlX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 20:41:23 -0500
Message-ID: <54C956AD.5040603@RedHat.com>
Date: Wed, 28 Jan 2015 16:37:49 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Eryu Guan <guaneryu@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] tests: fix typo and let make check work again
References: <1422260381-29231-1-git-send-email-guaneryu@gmail.com>
In-Reply-To: <1422260381-29231-1-git-send-email-guaneryu@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2015 03:19 AM, Eryu Guan wrote:
> Comments in bash starts with '#' not '*'
> 
> This has been broken since 2011 by
> 
> 1254448 pdate addres for Free Software Foundation
> 
> Signed-off-by: Eryu Guan <guaneryu@gmail.com>
> ---
>  tests/t0001-statd-basic-mon-unmon.sh | 2 +-
>  tests/test-lib.sh                    | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
Wow... These tests are actually being used! Fantastic! Committed!!

steved.

> 
> diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001-statd-basic-mon-unmon.sh
> index 51f0d22..92517a1 100755
> --- a/tests/t0001-statd-basic-mon-unmon.sh
> +++ b/tests/t0001-statd-basic-mon-unmon.sh
> @@ -16,7 +16,7 @@
>  #
>  # You should have received a copy of the GNU General Public License
>  # along with this program; if not, write to the Free Software Foundation, Inc.,
> -* 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
> +# 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
>  #
>  
>  . ./test-lib.sh
> diff --git a/tests/test-lib.sh b/tests/test-lib.sh
> index ce4ecff..57af37b 100644
> --- a/tests/test-lib.sh
> +++ b/tests/test-lib.sh
> @@ -16,7 +16,7 @@
>  #
>  # You should have received a copy of the GNU General Public License
>  # along with this program; if not, write to the Free Software Foundation, Inc.,
> -* 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
> +# 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
>  #
>  
>  # make sure $srcdir is set and sanity check it
> 

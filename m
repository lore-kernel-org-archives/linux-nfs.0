Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:57033 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab1HXXYX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 19:24:23 -0400
Message-ID: <4E55869B.9010402@panasas.com>
Date: Wed, 24 Aug 2011 16:17:47 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: NeilBrown <neilb@suse.de>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: PATCH/RFC: remove state from struct nfs4_state
References: <20110825084601.4d8fcdee@notabene.brown>
In-Reply-To: <20110825084601.4d8fcdee@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/24/2011 03:46 PM, NeilBrown wrote:
> 
<snip>
> diff --git a/include/linux/configfs.h b/include/linux/configfs.h
> index 3081c58..9723858 100644
> --- a/include/linux/configfs.h
> +++ b/include/linux/configfs.h
> @@ -15,8 +15,8 @@
>   *
>   * You should have received a copy of the GNU General Public
>   * License along with this program; if not, write to the
> - * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
> - * Boston, MA 021110-1307, USA.
> + * Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

You did not mean to add all these changes in this particular
patch, did you?

If you are at fixing this (snail mail) address. Can't you just
remove the darn thing, that no one ever care about. I thing
you don't need any address. But the most it should just be an
email. Please don't let us slave every time FSF changes the rent
(As your patch said about something else this address is set but
 is never used. Proof of - It was wrong for so many years and no
 one was hurt ;-) )

Boaz

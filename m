Return-Path: keyrings-bounces@linux-nfs.org
Date: Tue, 2 Dec 2014 09:49:04 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
To: David Howells <dhowells@redhat.com>
In-Reply-To: <12126.1417429021@warthog.procyon.org.uk>
Message-ID: <alpine.LRH.2.11.1412020947060.18348@namei.org>
References: <12126.1417429021@warthog.procyon.org.uk>
MIME-Version: 1.0
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [Keyrings] [GIT PULL] Keyrings (& NFS) fixes
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/keyrings>
List-Post: <mailto:keyrings@linux-nfs.org>
List-Help: <mailto:keyrings-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: keyrings-bounces@linux-nfs.org
Errors-To: keyrings-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 1 Dec 2014, David Howells wrote:

> Hi James,
> 
> Can you pass these patches on to Linus please?
> 
> The first one fixes the handling of maximum buffer size for key descriptions,
> fixing the size at 4095 + NUL char rather than whatever PAGE_SIZE happens to
> be and permits you to read back the full description without it getting
> clipped because some extra information got prepended.
> 
> The second and third fix a bug in NFS idmapper handling whereby a key
> representing a mapping between an id and a name expires and causing
> EKEYEXPIRED to be seen internally in NFS (which prevents the mapping from
> happening) rather than re-looking up the mapping.
> 
> Thanks,
> David
> ---
> The following changes since commit a6aacbde406eeb6f8fc218b2c6172825f5e73fcf:
> 
>   Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/zohar/linux-integrity into next (2014-11-19 21:36:07 +1100)
> 
> are available in the git repository at:
> 
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/keys-fixes-20141121
> 

Because these patches are going to current Linus, you need to apply these 
patches to a tree based on his tree, and send a pull req to me for that.


-- 
James Morris
<jmorris@namei.org>

_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings

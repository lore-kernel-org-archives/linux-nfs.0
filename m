Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54842 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225Ab3KLSGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 13:06:16 -0500
MIME-Version: 1.0
In-Reply-To: <20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk>
	<20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
Date: Tue, 12 Nov 2013 12:06:15 -0600
Message-ID: <CAH2r5ms3p4wNwGyDYF6sr=_iwG1dqAD=SaciSYdEUBuM129Zgg@mail.gmail.com>
Subject: Re: [PATCH 1/3] statxat: Provide IOC flags for Windows fs attributes
From: Steve French <smfrench@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        andreas.gruenbacher@gmail.com,
        samba-technical <samba-technical@lists.samba.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was experimenting with these flags when adding the per-file
compression support for cifs and smb2/smb3, and noticed that it would
be helpful to be able to display the FILE_ATTRIBUTE_ENCRYPTED flag
here too on get (ie to show that the file is encrypted at rest on the
server).   I am unsure whether displaying the "FILE_ATTRIBUTE_SPARSE"
is useful or not here but that is another obvious one.

And the other obvious flag to display would be
"FILE_ATTRIBUTE_INTEGRITY_STREAM" or equivalent (to indicate that this
file is protected by data and metadata checksums, perhaps btrfs and
other local file systems may even eventually allow you to configure
additional extra data/metadata integrity checks someday as well, not
just SMB3).

On Tue, Nov 12, 2013 at 11:35 AM, David Howells <dhowells@redhat.com> wrote:
> Provide IOC flags for Windows fs attributes so that they can be retrieved (or
> even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using statxat().
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  include/uapi/linux/fs.h |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index 6c28b61bb690..8b966f48dd41 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -191,10 +191,13 @@ struct inodes_stat_t {
>  #define FS_EXTENT_FL                   0x00080000 /* Extents */
>  #define FS_DIRECTIO_FL                 0x00100000 /* Use direct i/o */
>  #define FS_NOCOW_FL                    0x00800000 /* Do not cow file */
> +#define FS_HIDDEN_FL                   0x10000000 /* Windows hidden file attribute */
> +#define FS_SYSTEM_FL                   0x20000000 /* Windows system file attribute */
> +#define FS_ARCHIVE_FL                  0x40000000 /* Windows archive file attribute */
>  #define FS_RESERVED_FL                 0x80000000 /* reserved for ext2 lib */
>
> -#define FS_FL_USER_VISIBLE             0x0003DFFF /* User visible flags */
> -#define FS_FL_USER_MODIFIABLE          0x000380FF /* User modifiable flags */
> +#define FS_FL_USER_VISIBLE             0x7003DFFF /* User visible flags */
> +#define FS_FL_USER_MODIFIABLE          0x700380FF /* User modifiable flags */
>
>
>  #define SYNC_FILE_RANGE_WAIT_BEFORE    1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,

Steve

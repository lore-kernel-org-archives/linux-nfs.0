Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:59826 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468Ab3ABC7C convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jan 2013 21:59:02 -0500
Received: by mail-ie0-f181.google.com with SMTP id 16so16100928iea.26
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jan 2013 18:59:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50D92E0F.2050909@davequigley.com>
References: <cd02d79979bf6c825152f3bcf3a7f33d@countercultured.net>
	<50D92E0F.2050909@davequigley.com>
Date: Wed, 2 Jan 2013 10:59:01 +0800
Message-ID: <CAPihpKDeELRqOLKCxQqbRONkqVcZdDgBk8yzbC4WrvukXavHrg@mail.gmail.com>
Subject: Re: Labeled NFS Meeting Info for Tonight Dec 20/Dec 21st for our
 friends in Singapore
From: Rodel Miguel <rodelfmiguel@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: joseph_vu@hotmail.com, steved@redhat.com, trond.myklebust@netapp.com,
        bfields@fieldses.org, rodel_fm@dsi.a-star.edu.sg,
        casey@schaufler-ca.com, selinux@tycho.nsa.gov,
        Dave Quigley <dpquigl@davequigley.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 25, 2012 at 12:39 PM, Dave Quigley <dpquigl@davequigley.com> wrote:
> The notes below summarize what we decided during out last meeting. It also
> has our next meeting date. There are some more issues that need to be fixes
>
>
> Shooting for merge window 3.9.
>
> List of things to do:
>
> Add warning fixup patch into tree (Dave Q)
> Patch to cleanup comment for dentry_init_security (Dave Q)
> Patch to cleanup comment to reflect that xattrs aren’t being used in the
> protocol (ismaclabel lsm hook) (Dave Q)
>
> Patch to remove export option (SteveD)
> Patch to fix ifdefs in client (SteveD)
> Patch to fix ifdefs in server (SteveD)
> Patch to remove bugons (Dave)
>
> Rodel:
>
> Work on making our attribute encoding/decoding work more like
> encode/decode_fsinfo. This means removing the extend fattr to use 3rd word
> patch and instead placing the information inside an op specific struct.
> Work on Attribute change notification:
> Smaller patches if possible (client, server, support, etc...)
>
> Leaving RPCSECGSSv3 for now.
>
> January 10th next Meeting.
>
> Dave
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

I would like to make sure that I understand Trond's feedback on the
current LNFS implementation.

1. Do we need to remove the "decode_attr_security_label" function from
"decode_getfattr_attrs" and have our own operation to exchange
security labels instead of piggy-backing labeled NFS request on
setting/getting file attributes?
2. Do we need to remove the FATTR4_WORD2_SECURITY_LABEL from the
nfs4_fattr_bitmap and exchange this information separately on a new
function, say decode/encode_security_label?

Please comment if this is in-line with everyone's line of thought
regarding the suggested change: "Work on making our attribute
encoding/decoding work more like encode/decode_fsinfo. This means
removing the extend fattr to use 3rd word patch and instead placing
the information inside an op specific struct."

Thank you very much!

Kind Regards,
Rodel

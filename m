Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78800ECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 14:10:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 377C820836
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 14:10:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 377C820836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727096AbeJUWYy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 18:24:54 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:35698 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727266AbeJUWYy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 18:24:54 -0400
Received: by mail-qk1-f194.google.com with SMTP id v68-v6so23785993qka.2
        for <linux-nfs@vger.kernel.org>; Sun, 21 Oct 2018 07:10:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zblXWDmCEP08dN/MOohOkRq9VuCP9BPsaRMuVsRWlto=;
        b=X0VAQ4aKVx/9AjnjjnfAwm/c2Hc0R2CN9iRro+uCqASp9R1pajJETVM7NesEQF7OrE
         6hbro/Xfcc8oN0YxN8rC6CBLmXLe1oBkHeP048meee9U6mw/7F19HL1y61l9k23ZUHeY
         FTkB+ZLq+wYvRMDKe+fL5NxaCPtBDzlAMQCJAyguXwhMEK6xaCYOSHdKTwsJuUH+xq1h
         eoGluTW4HNFetjbRrkn3MCXm8Sy7rp/EwZ5jVNZUx4tRk+fBWtAVc7gxMgfwUCBhi6xS
         62VYPFzedSf38r5dwG3K3dXK0RWnlu7jBkOBeLjHLmq/ohtQJGqllb4moff+VdjaPQBW
         4jFQ==
X-Gm-Message-State: ABuFfogIhbvpiVnZ6FPywjRSB/rqaM5WPKEwAq3kEYDkbVZ/dl+rRMzE
        1eSYRUuvpB8LKHJej8nbjXckMw==
X-Google-Smtp-Source: ACcGV6167mG4Hm7uy52rU7DGb6wxOj14JsK4bT/xL0QxjSs5PY3jEfQQHJftZI3sCOLlwSFx5+xSUg==
X-Received: by 2002:a37:711:: with SMTP id 17-v6mr16574333qkh.64.1540131024493;
        Sun, 21 Oct 2018 07:10:24 -0700 (PDT)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-790.dyn6.twc.com. [2606:a000:1100:db::790])
        by smtp.gmail.com with ESMTPSA id f44-v6sm26356249qtc.42.2018.10.21.07.10.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 Oct 2018 07:10:23 -0700 (PDT)
Message-ID: <b2f656abd4bac72f7ba896e1d6af1b944d28dab9.camel@redhat.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
From:   Jeff Layton <jlayton@redhat.com>
To:     Matthew Wilcox <willy@infradead.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        fweimer@redhat.com, smfrench@gmail.com
Date:   Sun, 21 Oct 2018 10:10:22 -0400
In-Reply-To: <20181019175822.GB28891@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
         <20181019153018.32507-2-olga.kornievskaia@gmail.com>
         <20181019175822.GB28891@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-19 at 10:58 -0700, Matthew Wilcox wrote:
> On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > +++ b/Documentation/filesystems/vfs.txt
> > @@ -958,7 +958,9 @@ otherwise noted.
> >  
> >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> >  
> > -  copy_file_range: called by the copy_file_range(2) system call.
> > +  copy_file_range: called by copy_file_range(2) system call. This method
> > +		   works on two file descriptors that might reside on
> > +		   different superblocks of the same type of file system.
> 
> I don't think this text is explicit enough about what has changed, and I
> think this is the wrong place for it.  I think there should be a paragraph
> in Documentation/filesystems/porting and it should follow the current style
> in there.
> 
> > @@ -1591,7 +1587,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >  	 * Try cloning first, this is supported by more file systems, and
> >  	 * more efficient if both clone and copy are supported (e.g. NFS).
> >  	 */
> > -	if (file_in->f_op->clone_file_range) {
> > +	if (inode_in->i_sb == inode_out->i_sb &&
> > +			file_in->f_op->clone_file_range) {
> 
> This reads weirdly to me.  I know it's the same order the tests were done
> in before, but it would feel more natural to me to test:
> 
> 	if (file_in->f_op->clone_file_range &&
> 			inode_in->i_sb == inode_out->i_sb)
> 
> Am I just suffering from "I would have done this differently"itis, or
> is it unnatural?
> 
> > @@ -1600,10 +1597,12 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> >  		}
> >  	}
> >  
> > -	if (file_out->f_op->copy_file_range) {
> > +	if (file_out->f_op->copy_file_range &&
> > +			(file_in->f_op->copy_file_range ==
> > +				file_out->f_op->copy_file_range)) {
> 
> Can we avoid this extra test here?  I know the various stamdards groups
> including T10 and the IETF have been trying to define a universal
> identifier for the same blob of storage, no matter how it's accessed;
> potentially allowing access to the same storage across iSCSI, CIFS
> and NFS.  If we ever get to a point where we support that (and I am
> dubious), we'd want to remove this test again, and have to revalidate
> all the filesystems.
> 

Agreed. I think this really ought to be left up to the lower fs. Pass
the op both struct file pointers and let it sort it out.

We just need to document the expectation that file copy_file_range ops
vet file_in carefully as it could be from anything, and have them return
an appropriate error code if it's not something they can deal with.
-- 
Jeff Layton <jlayton@redhat.com>


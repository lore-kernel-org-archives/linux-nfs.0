From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: I want to build complete pNFS-set
Date: Wed, 26 May 2010 10:57:13 +0300
Message-ID: <4BFCD459.5040709@panasas.com>
References: <loom.20100526T075412-30@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: redshield88888 <redshield88888@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53256 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab0EZH52 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 03:57:28 -0400
Received: by fxm5 with SMTP id 5so4068359fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 00:57:27 -0700 (PDT)
In-Reply-To: <loom.20100526T075412-30-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, maybe Boaz wasn't clear enough but although it CAN be done
the MDS in the current implementation is not highly available.

Benny

On May. 26, 2010, 9:02 +0300, redshield88888 <redshield88888@gmail.com> wrote:
> Hi all
> 
> Is there a document that contains how to construct high-available pNFS
> constituions using the osd-target, the exofs, and the objlayoutdriver ?
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


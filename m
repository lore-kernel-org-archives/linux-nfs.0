Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14541 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428Ab3K0PCe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 10:02:34 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Albert Fluegel <af@muc.de>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Wed, 27 Nov 2013 15:02:33 +0000
Message-ID: <894EFA1F-C576-4A36-8589-9B645E0742BF@netapp.com>
References: <20131127084300.GA37104@colin.muc.de>
In-Reply-To: <20131127084300.GA37104@colin.muc.de>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I’ll update the bugzilla and ask redhat to backport this once it’s accepted by Trond.

-dros

On Nov 27, 2013, at 3:43 AM, Albert Fluegel <af@muc.de> wrote:

> Hi,
> 
> sorry, i missed and deleted this posting from Weston Andros Adamson:
> http://www.spinics.net/lists/linux-nfs/msg40622.html
> so i cannot directly reply anymore. Apologies for messing up the mail
> threads a bit.
> 
> I reported this issue to Redhat 2012-10-25, please see here:
> https://bugzilla.redhat.com/show_bug.cgi?id=869942
> and suggested a fix. I'd greatly appreciate, if someone could confirm
> to Redhat, that the problem and the approach to fix that is basically the
> same, so they'll hopefully backport the patch.
> 
> Thank you very much,
> Albert
> 
> -- 
> Albert Flügel
> Lindwurmstraße 51
> 80337 München
> Telefon: +49-89-2010895
> Telefon: +49-170-5665444
> E-Mail: af@muc.de
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~~~~~~~~~~~ jslwkerbiS4kjaZoifUSDfaworu394kjKLw728K2L1NlwkNSD8 ~~~~~~~~~~~~~
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


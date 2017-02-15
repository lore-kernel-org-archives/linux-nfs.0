Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50481 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751505AbdBOSGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Feb 2017 13:06:24 -0500
Subject: Re: [PATCH 0/2] RFC: Libtirpc changes for RPCSEC_GSS version 3
To: "Adamson, Andy" <William.Adamson@netapp.com>
References: <1482509367-22381-1-git-send-email-andros@netapp.com>
 <9495725a-8ca0-5173-15e4-cd6a6dc27e40@RedHat.com>
 <8F2B2A30-49CB-42B3-81C5-6C0965A55672@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <696b7abc-fd79-822b-3cde-33280961f5bf@RedHat.com>
Date: Wed, 15 Feb 2017 13:06:23 -0500
MIME-Version: 1.0
In-Reply-To: <8F2B2A30-49CB-42B3-81C5-6C0965A55672@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/15/2017 10:21 AM, Adamson, Andy wrote:

> Yes, there are kernel pieces needed. “"RFC: RPCSEC_GSS Version 3 prototype: Full MOde MAC”, as well as the gssd patches.  I am working on a version-5 of the kernel GSS3 patches and hope to submit today or tomorrow. My current issue is that the setting of the client thread label transported by gssv3 has stopped working (in nfsd_setuser) with the later kernels….
Just go ahead a ping me when these are ready to go.... Thanks!

steved.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53412 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753723Ab3GTNH0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Jul 2013 09:07:26 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 1/1] NFSv4.1 Increase NFS4_DEF_SLOT_TABLE_SIZE
Date: Sat, 20 Jul 2013 13:07:24 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93F488FF1@SACEXCMBX04-PRD.hq.netapp.com>
References: <1374268191-4469-1-git-send-email-andros@netapp.com>
 <D8BB2DCD-4166-4425-8C08-EF0CCA9B926D@oracle.com>
In-Reply-To: <D8BB2DCD-4166-4425-8C08-EF0CCA9B926D@oracle.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Friday, July 19, 2013 7:57 PM
> To: Adamson, Andy
> Cc: Linux NFS Mailing List
> Subject: Re: [PATCH 1/1] NFSv4.1 Increase NFS4_DEF_SLOT_TABLE_SIZE
> 
> Hi Andy-
> 
> On Jul 19, 2013, at 5:09 PM, andros@netapp.com wrote:
> 
> > From: Andy Adamson <andros@netapp.com>
> >
> > max_session_slots is a ushort. Bump NFS4_DEF_SLOT_TABLE_SIZE to the
> > max ushort
> > value: e.g. ask for 256 slots and let the server negotiate down if needed.
> 
> I don't have an objection to your patch, but the description is confusing.
> 
> In fs/nfs/super.c I see
> 
>    unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
> 
> but /usr/include/limits.h has
> 
>    #define USHRT_MAX 65535
> 
> The maximum value you can store in an unsigned octet is 255 (UCHAR_MAX).
> 
> Why did you choose 256 and not 65535?

This is the _minimum_ number of slots that the client and server will have to allocate, even when they both support dynamic slots, so we don't want to set it unreasonably high.
I realise that most servers will negotiate this value down, but we don't want to rely on that.

Cheers
  Trond

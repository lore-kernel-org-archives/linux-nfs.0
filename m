Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41027 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603Ab2LKTBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 14:01:53 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 11 Dec 2012 14:01:52 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 988006E8053
	for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2012 14:01:48 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBBJ1mkk310398
	for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2012 14:01:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBBJ1mWk008353
	for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2012 14:01:48 -0500
In-Reply-To: <50C71712.2030909@tonian.com>
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com>	<50C45D17.5090000@tonian.com> <OFA6E36E77.727ADDF2-ON88257ACF.005B56C9-88257ACF.005BE4BB@us.ibm.com> <CAEMWVhsh0SvLX8MY8cghOmbYExpqFLYgUFVuai_RyaYu3EErvw@mail.gmail.com> <OF0F796F1E.99986A09-ON88257ACF.0063225B-88257ACF.0063629E@us.ibm.com> <50C71712.2030909@tonian.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@netapp.com>, nfsv4@ietf.org
MIME-Version: 1.0
Subject: Re: notify_deviceid_type4
Message-ID: <OF8606E01D.38BFFF7E-ON88257AD1.0067EE8C-88257AD1.006889C8@us.ibm.com>
From: Marc Eshel <eshel@us.ibm.com>
Date: Tue, 11 Dec 2012 11:01:45 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That sound like the correct thing to do, I which we have the agreement 
from all implementations to make sure we all do the same thing. I will 
copy the ietf mailing list to see that there are no objections. I guess we 
will find out in the next cton what breaks.
Marc.

Benny Halevy <bhalevy@tonian.com> wrote on 12/11/2012 03:20:50 AM:

> From: Benny Halevy <bhalevy@tonian.com>
> To: Marc Eshel/Almaden/IBM@IBMUS, 
> Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-
> nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@netapp.com>, 
> Trond Myklebust <trond.myklebust@netapp.com>
> Date: 12/11/2012 03:21 AM
> Subject: Re: notify_deviceid_type4
> 
> On 2012-12-09 20:05, Marc Eshel wrote:
> > Can you provide with the spec information that supports your 
> > interpretation?
> 
> Marc, section 18.40.3. says the following:
> 
>    The notification mask is
>    composed in the same manner as the bitmap for file attributes
>    (Section 3.3.7).  The numbers of bit positions are listed in the
>    notify_device_type4 enumeration type (Section 20.12).
> 
> The linux implementation chose to reflect the bit masks in the header
> file rather than the bit numbers but it's clear the masks should equal
> 2 (1<<1) and 4 (1<<2) rather than 1 and 2.
> 
> For clarity, I'm OK with a patch that fixes the definition in nfs4.h to:
> 
> enum pnfs_notify_deviceid_type4 {
>          NOTIFY_DEVICEID4_CHANGE = 1,
>          NOTIFY_DEVICEID4_DELETE = 2,
> };
> 
> But every place these values are currently used verbatim should be fixed
> respectively to use the shifted value, e.g. (1 << 
NOTIFY_DEVICEID4_CHANGE).
> 
> Benny
> 
> > Marc.
> > 
> > 
> > 
> > From:   Benny Halevy <bhalevy@tonian.com>
> > To:     Marc Eshel/Almaden/IBM@IBMUS, 
> > Cc:     linux-nfs-owner@vger.kernel.org, Trond Myklebust 
> > <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org, "J. Bruce 
Fields" 
> > <bfields@redhat.com>
> > Date:   12/09/2012 09:50 AM
> > Subject:        Re: notify_deviceid_type4
> > 
> > 
> > 
> > The enum values in the spec correspond to bit _numbers_ in the bitmap, 
not 
> > to bitmasks.
> > On Dec 9, 2012 6:43 PM, "Marc Eshel" <eshel@us.ibm.com> wrote:
> > I am not sure what you are saying, I am showing the definition from 
the
> > spec. that show NOTIFY_DEVICEID4_CHANGE = 1, and nfs4.h has it as (1<< 
1)
> > which is not 1, it is 2.
> > Marc.
> > 
> > Benny Halevy <bhalevy@tonian.com> wrote on 12/09/2012 01:42:47 AM:
> > 
> >> From: Benny Halevy <bhalevy@tonian.com>
> >> To: Marc Eshel/Almaden/IBM@IBMUS,
> >> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "J. Bruce Fields"
> >> <bfields@redhat.com>, linux-nfs-owner@vger.kernel.org, linux-
> >> nfs@vger.kernel.org
> >> Date: 12/09/2012 01:44 AM
> >> Subject: Re: notify_deviceid_type4
> >>
> >> On 2012-12-01 07:54, Marc Eshel wrote:
> >>> The spec defines notify_deviceid_type4 as:
> >>>
> >>> 20.12.1.  ARGUMENT
> >>>    /*
> >>>     * Device notification types.
> >>>     */
> >>>    enum notify_deviceid_type4 {
> >>>            NOTIFY_DEVICEID4_CHANGE = 1,
> >>>            NOTIFY_DEVICEID4_DELETE = 2
> >>>    };
> >>>
> >>>
> >>> but the Linux code in nfs4.h has, is that going to be fixed?
> >>>
> >>> enum pnfs_notify_deviceid_type4 {
> >>>         NOTIFY_DEVICEID4_CHANGE = 1 << 1,
> >>>         NOTIFY_DEVICEID4_DELETE = 1 << 2,
> >>> };
> >>
> >> notify_deviceid_type4 specifies bit numbers same as notify_type4
> >> It seems to me like the definition in nfs4.h is correct.
> >>
> >> Benny
> >>
> >>>
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >>
> > 
> > 
> 
> -- 
> Benny Halevy
> CTO, Tonian Inc.
> 
> Tel: +972-54-802-8340
> bhalevy@tonian.com
> 


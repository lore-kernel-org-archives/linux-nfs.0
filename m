Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:45377 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab2LISFi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Dec 2012 13:05:38 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Sun, 9 Dec 2012 13:05:37 -0500
In-Reply-To: <CAEMWVhsh0SvLX8MY8cghOmbYExpqFLYgUFVuai_RyaYu3EErvw@mail.gmail.com>
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com>	<50C45D17.5090000@tonian.com>
	<OFA6E36E77.727ADDF2-ON88257ACF.005B56C9-88257ACF.005BE4BB@us.ibm.com> <CAEMWVhsh0SvLX8MY8cghOmbYExpqFLYgUFVuai_RyaYu3EErvw@mail.gmail.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org,
        Trond Myklebust <trond.myklebust@netapp.com>
MIME-Version: 1.0
Subject: Re: notify_deviceid_type4
Message-ID: <OF0F796F1E.99986A09-ON88257ACF.0063225B-88257ACF.0063629E@us.ibm.com>
From: Marc Eshel <eshel@us.ibm.com>
Date: Sun, 9 Dec 2012 10:05:27 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can you provide with the spec information that supports your 
interpretation?
Marc.



From:   Benny Halevy <bhalevy@tonian.com>
To:     Marc Eshel/Almaden/IBM@IBMUS, 
Cc:     linux-nfs-owner@vger.kernel.org, Trond Myklebust 
<trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org, "J. Bruce Fields" 
<bfields@redhat.com>
Date:   12/09/2012 09:50 AM
Subject:        Re: notify_deviceid_type4



The enum values in the spec correspond to bit _numbers_ in the bitmap, not 
to bitmasks.
On Dec 9, 2012 6:43 PM, "Marc Eshel" <eshel@us.ibm.com> wrote:
I am not sure what you are saying, I am showing the definition from the
spec. that show NOTIFY_DEVICEID4_CHANGE = 1, and nfs4.h has it as (1<< 1)
which is not 1, it is 2.
Marc.

Benny Halevy <bhalevy@tonian.com> wrote on 12/09/2012 01:42:47 AM:

> From: Benny Halevy <bhalevy@tonian.com>
> To: Marc Eshel/Almaden/IBM@IBMUS,
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "J. Bruce Fields"
> <bfields@redhat.com>, linux-nfs-owner@vger.kernel.org, linux-
> nfs@vger.kernel.org
> Date: 12/09/2012 01:44 AM
> Subject: Re: notify_deviceid_type4
>
> On 2012-12-01 07:54, Marc Eshel wrote:
> > The spec defines notify_deviceid_type4 as:
> >
> > 20.12.1.  ARGUMENT
> >    /*
> >     * Device notification types.
> >     */
> >    enum notify_deviceid_type4 {
> >            NOTIFY_DEVICEID4_CHANGE = 1,
> >            NOTIFY_DEVICEID4_DELETE = 2
> >    };
> >
> >
> > but the Linux code in nfs4.h has, is that going to be fixed?
> >
> > enum pnfs_notify_deviceid_type4 {
> >         NOTIFY_DEVICEID4_CHANGE = 1 << 1,
> >         NOTIFY_DEVICEID4_DELETE = 1 << 2,
> > };
>
> notify_deviceid_type4 specifies bit numbers same as notify_type4
> It seems to me like the definition in nfs4.h is correct.
>
> Benny
>
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>



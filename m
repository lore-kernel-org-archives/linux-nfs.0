Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45394 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787Ab2LIQn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Dec 2012 11:43:59 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Sun, 9 Dec 2012 11:43:57 -0500
In-Reply-To: <50C45D17.5090000@tonian.com>
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com> <50C45D17.5090000@tonian.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Subject: Re: notify_deviceid_type4
Message-ID: <OFA6E36E77.727ADDF2-ON88257ACF.005B56C9-88257ACF.005BE4BB@us.ibm.com>
From: Marc Eshel <eshel@us.ibm.com>
Date: Sun, 9 Dec 2012 08:43:37 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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


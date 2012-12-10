Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:47345 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab2LJMBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2012 07:01:11 -0500
Received: by mail-wi0-f170.google.com with SMTP id hq7so1093161wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2012 04:01:10 -0800 (PST)
Message-ID: <50C5CEFE.6090107@tonian.com>
Date: Mon, 10 Dec 2012 14:01:02 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
CC: Marc Eshel <eshel@us.ibm.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>
Subject: Fwd: Re: notify_deviceid_type4
References: <CAEMWVhtv8LXqVjctmGDkc4bDCQ_V7_caL5HxN3t7MvPPVd58WQ@mail.gmail.com>
In-Reply-To: <CAEMWVhtv8LXqVjctmGDkc4bDCQ_V7_caL5HxN3t7MvPPVd58WQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, my original post was bounced due to containing html.
Forwarding to the list.

Benny


-------- Original Message --------
Subject: 	Re: notify_deviceid_type4
Date: 	Mon, 10 Dec 2012 08:57:29 +0200
From: 	Benny Halevy <bhalevy@tonian.com>
To: 	Marc Eshel <eshel@us.ibm.com>
CC: 	NFS list <linux-nfs@vger.kernel.org>, Trond Myklebust <trond.myklebust@netapp.com>, "J. Bruce Fields" <bfields@redhat.com>, linux-nfs-owner@vger.kernel.org


On Dec 9, 2012 11:47 PM, "Marc Eshel" <eshel@us.ibm.com <mailto:eshel@us.ibm.com>> wrote:
>
> So you are saying it should be:
>
> enum pnfs_notify_deviceid_type4 {
>          NOTIFY_DEVICEID4_CHANGE = 1 << 0,
>          NOTIFY_DEVICEID4_DELETE = 1 << 1,
> };

Maybe theoretically but the spec already defined it skipping the first bit.  I'm not sure why. Probably just a mistake.

Benny

>
>
>
> From:   Benny Halevy <bhalevy@tonian.com <mailto:bhalevy@tonian.com>>
> To:     Marc Eshel/Almaden/IBM@IBMUS,
> Cc:     linux-nfs-owner@vger.kernel.org <mailto:linux-nfs-owner@vger.kernel.org>, NFS list
> <linux-nfs@vger.kernel.org <mailto:linux-nfs@vger.kernel.org>>, "J. Bruce Fields" <bfields@redhat.com <mailto:bfields@redhat.com>>, Trond
> Myklebust <trond.myklebust@netapp.com <mailto:trond.myklebust@netapp.com>>
> Date:   12/09/2012 11:54 AM
> Subject:        Re: notify_deviceid_type4
>
>
>
> I'm not sure if and whete that's saud explicitly but another example to
> support that inrerpretation are the values of notify_type4 that apply to
> the same bitmap that too are defined as sequential numbers (though zero
> based) and not as single bit masks.
> Benny
> On Dec 9, 2012 8:05 PM, "Marc Eshel" <eshel@us.ibm.com <mailto:eshel@us.ibm.com>> wrote:
> Can you provide with the spec information that supports your
> interpretation?
> Marc.
>
>
>
> From:   Benny Halevy <bhalevy@tonian.com <mailto:bhalevy@tonian.com>>
> To:     Marc Eshel/Almaden/IBM@IBMUS,
> Cc:     linux-nfs-owner@vger.kernel.org <mailto:linux-nfs-owner@vger.kernel.org>, Trond Myklebust
> <trond.myklebust@netapp.com <mailto:trond.myklebust@netapp.com>>, linux-nfs@vger.kernel.org <mailto:linux-nfs@vger.kernel.org>, "J. Bruce Fields"
> <bfields@redhat.com <mailto:bfields@redhat.com>>
> Date:   12/09/2012 09:50 AM
> Subject:        Re: notify_deviceid_type4
>
>
>
> The enum values in the spec correspond to bit _numbers_ in the bitmap, not
> to bitmasks.
> On Dec 9, 2012 6:43 PM, "Marc Eshel" <eshel@us.ibm.com <mailto:eshel@us.ibm.com>> wrote:
> I am not sure what you are saying, I am showing the definition from the
> spec. that show NOTIFY_DEVICEID4_CHANGE = 1, and nfs4.h has it as (1<< 1)
> which is not 1, it is 2.
> Marc.
>
> Benny Halevy <bhalevy@tonian.com <mailto:bhalevy@tonian.com>> wrote on 12/09/2012 01:42:47 AM:
>
> > From: Benny Halevy <bhalevy@tonian.com <mailto:bhalevy@tonian.com>>
> > To: Marc Eshel/Almaden/IBM@IBMUS,
> > Cc: Trond Myklebust <Trond.Myklebust@netapp.com <mailto:Trond.Myklebust@netapp.com>>, "J. Bruce Fields"
> > <bfields@redhat.com <mailto:bfields@redhat.com>>, linux-nfs-owner@vger.kernel.org <mailto:linux-nfs-owner@vger.kernel.org>, linux-
> > nfs@vger.kernel.org <mailto:nfs@vger.kernel.org>
> > Date: 12/09/2012 01:44 AM
> > Subject: Re: notify_deviceid_type4
> >
> > On 2012-12-01 07:54, Marc Eshel wrote:
> > > The spec defines notify_deviceid_type4 as:
> > >
> > > 20.12.1.  ARGUMENT
> > >    /*
> > >     * Device notification types.
> > >     */
> > >    enum notify_deviceid_type4 {
> > >            NOTIFY_DEVICEID4_CHANGE = 1,
> > >            NOTIFY_DEVICEID4_DELETE = 2
> > >    };
> > >
> > >
> > > but the Linux code in nfs4.h has, is that going to be fixed?
> > >
> > > enum pnfs_notify_deviceid_type4 {
> > >         NOTIFY_DEVICEID4_CHANGE = 1 << 1,
> > >         NOTIFY_DEVICEID4_DELETE = 1 << 2,
> > > };
> >
> > notify_deviceid_type4 specifies bit numbers same as notify_type4
> > It seems to me like the definition in nfs4.h is correct.
> >
> > Benny
> >
> > >
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> > > the body of a message to majordomo@vger.kernel.org <mailto:majordomo@vger.kernel.org>
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >
> >
>
>
>




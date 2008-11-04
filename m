From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: gssapi and nfs4
Date: Tue, 4 Nov 2008 13:00:24 -0500
Message-ID: <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com>
References: <1225813410.2247.279.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:40781 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbYKDSK1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2008 13:10:27 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2790831fgg.17
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2008 10:10:25 -0800 (PST)
In-Reply-To: <1225813410.2247.279.camel@brian-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

On Tue, Nov 4, 2008 at 10:43 AM, Brian J. Murrell <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org> wrote:
> Hi all,
>
> So, as I stated previously, I've migrated a few of my mounts to nfs4
> with gssapi to solve the limit of 16 supplemental groups issue with the
> SYS security model.
>
> I have taken notice of the gssapi export specification:
>
> /mnt/data       gss/krb5i(<export_options>)

In general, the instructions at the CITI web site will be useful.

>From http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html:

Mounting and exporting krb5

To mount a filesystem using krb5, provide the "-osec=krb5" option to mount.

To export a filesystem using krb5, add the export option "sec=krb5".
(Note: if your kernel is older than 2.6.23, or nfs-utils older than
1.1.1, you will instead need to export to a special client named
"gss/krb5".)

>
> So with gssapi, gone is the concept of limiting exports to ip/netmasks
> as well as exporting to different machines (as identified by
> ip/netmasks) with different export options.  Is that correct?

So instead of using the old "gss/krb5" which indeed did replace the
ip/netmasks list, you can now specify the use of gssapi with an export
option, and still set ip/netmasks.


-->Andy

> How do those concepts map to gssapi then?
>
> I realize that being a newbie to this gssapi use of nfs, this is all
> probably pretty basic for most everyone here.  Is there some documents
> that you could suggest for a person familiar with the SYS/nfs3 security
> model to read in understanding the concepts of GSS/nfs4.  Or if you are
> willing to entertain my newbie questions, let me know and I will ask
> away, but I don't want to presume.
>
> Thanx,
> b.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

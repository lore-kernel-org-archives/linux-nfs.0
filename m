From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: Got error -10052 from the server on DESTROY_SESSION. Session has
	been destroyed regardless...
Date: Tue, 8 Jun 2010 09:42:35 -0700
Message-ID: <AANLkTinzsVkmZBAqXxQpBScy71L6DSUlYiRwa_kZAicN@mail.gmail.com>
References: <4C0E6C37.3040504@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:41190 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545Ab0FHQmh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 12:42:37 -0400
Received: by pvg16 with SMTP id 16so2000401pvg.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 09:42:36 -0700 (PDT)
In-Reply-To: <4C0E6C37.3040504@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any other operations during that time ? Like a COMMIT or a CLOSE maybe?

-alexandros

On Tue, Jun 8, 2010 at 9:13 AM, Boaz Harrosh <bharrosh@panasas.com> wro=
te:
>
> On 2.6.35-rc2-pnfs I get:
>
> Got error -10052 from the server on DESTROY_SESSION. Session has been=
 destroyed regardless...
>
> at end of cthon test. And it has hard time umounting. After some seco=
nds it is able to umount
> Am investigating. Has any one seen this?
>
> Boaz
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

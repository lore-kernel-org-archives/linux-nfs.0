Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f182.google.com ([209.85.128.182]:36042 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaGGVYx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 17:24:53 -0400
Received: by mail-ve0-f182.google.com with SMTP id oy12so4691493veb.41
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 14:24:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <lpehhl$o74$1@ger.gmane.org>
References: <lp1gar$eb6$1@ger.gmane.org>
	<CAHVgHyVjoVb--cfbaopoUYA4vbDCjufJVng6OM2e82q0yEMthA@mail.gmail.com>
	<lpehhl$o74$1@ger.gmane.org>
Date: Mon, 7 Jul 2014 17:24:52 -0400
Message-ID: <CAHVgHyWU9B+VE=_qTEG2TVOyMHijzVTA0a2rVb_7hrjsKf7Jfw@mail.gmail.com>
Subject: Re: NFSv4 cross-realm support
From: Andy Adamson <androsadamson@gmail.com>
To: Jaap Winius <jwinius@umrk.nl>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 7, 2014 at 12:23 PM, Jaap Winius <jwinius@umrk.nl> wrote:
> On Mon, 07 Jul 2014 08:36:00 -0400, Andy Adamson wrote:
>
>> So you are supporting two Kerberos realms under one NFSv4 domain?
>
> At some point I even hope to make it three Kerberos realms under one
> NFSv4 domain, but this also depends on a cross-realm issue with Exim4
> being resolved, so for now it's just two realms under one NFSv4 domain.
>
>> You are using LDAP for id mapping?
>
> Yes. After tweaking the user-olcAuthzRegexp for cn=config it seems to be
> working perfectly.

I have never used the olcAuthzRegexp. Is this used to map potentially
multiple principal@REALM names to the same UID name/number?

-->Andy

>
>> Which version of nfs-utils and which client kernel?
>
> I'm using Debian wheezy (stable), which comes with with nfs-common
> 1.2.6-4 and kernel 3.2.0-4-amd64.
>
> Cheers,
>
> Jaap
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

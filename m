Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7782C43219
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 21:14:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0B8A206BA
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 21:14:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="DLAXaCmV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727468AbfDYVO0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 17:14:26 -0400
Received: from mail-wr1-f68.google.com ([209.85.221.68]:34164 "EHLO
        mail-wr1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726830AbfDYVO0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2019 17:14:26 -0400
Received: by mail-wr1-f68.google.com with SMTP id c6so1366977wrm.1
        for <linux-nfs@vger.kernel.org>; Thu, 25 Apr 2019 14:14:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=Lc6qTZfLyRN9w+Iayh0z63UHZdquyrcbISXK9Sap7E8=;
        b=DLAXaCmVKnZS9/5SX1ConRBbwuqW5uXEzjnXq37jfO92hWs9NOKjRTAbq7/JNUnEmm
         OY9G7Qp0o12RrmhzovBDwlvC5WpMaTorV/JH+kUnbTq1g1i0CTGLArl/ZJcWvj6jZ1I0
         Gr3HtERBplqBzFiVs5AAxss7LgoO4lwbFrIjbnCDJmpzL7hQSGYrJw5E05hbmkI5yMLN
         v+kJ9QSsS3mQMSi478Ve35DkeyuCq/63kS+H+KnWDjbe+1+li5Z3w9bwIiWOfTe/nObZ
         hWqGLblTnoqZNMbLnGWng1A8tFS/RPrhSbxx5lSv9n/JdDFgId8jzItNHGijiyWofvrL
         UyEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:message-id:mime-version:subject:date
         :in-reply-to:cc:to:references;
        bh=Lc6qTZfLyRN9w+Iayh0z63UHZdquyrcbISXK9Sap7E8=;
        b=RG+fz0lMVkABJlOLtOv5hbOFCo8DJC9+oudbdAVwSTH9KAdmogcGhjpuNdo0Tj2Euk
         peQuf3ek1aUYMP/BoUyENnj7pQqMP8/Ex98SbLtNqfr1G6cnb9dx1J92UgKB8rC1r1nv
         5S/lwEl/8InRQ6m1jPbrKWTBwR7WUgibDKlxLCHpeHhzijNoqKoIEvfIpGRGlAc+nDr5
         9To/2aikTrlMpIFGcDo4+Vy753iFdmU+ev21HYo27P/gTDlgIn4r2j52YPOGv7qawAHe
         6EKbo9fnyWtIdBELUv9uihITtXFHTfZFGtMEZbKEYzkXWuO93NDgPj3Vr0/T4Grrxp5j
         RNuQ==
X-Gm-Message-State: APjAAAUix4x6eShLh4OoVg3C31Wmesb7x5EF2db4NDw7lhG8ce2cyz5M
        7m3aDr6BzMDNGZnGXeXMcWpnYg==
X-Google-Smtp-Source: APXvYqyo6mxZEu03qqOBUfEAf/Sjy5s4sYTMb8RJZCM3r45UMk2irjCaYmLsKTfs61mMbHTacAqlCg==
X-Received: by 2002:adf:ed90:: with SMTP id c16mr920478wro.74.1556226864321;
        Thu, 25 Apr 2019 14:14:24 -0700 (PDT)
Received: from surfer-172-29-5-61-hotspot.internet-for-guests.com ([185.37.136.130])
        by smtp.gmail.com with ESMTPSA id i18sm21401514wrm.7.2019.04.25.14.14.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:14:23 -0700 (PDT)
From:   Andreas Dilger <adilger@dilger.ca>
Message-Id: <7F460FEA-BD69-4559-926C-5C1B0CF90E3C@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_EB3E3A59-94EE-44CC-8383-078B4B992E50";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 08/10] nfsd4: add file to display list of client's opens
Date:   Thu, 25 Apr 2019 23:14:23 +0200
In-Reply-To: <20190425201413.GB9889@fieldses.org>
Cc:     Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org
To:     "J. Bruce Fields" <bfields@fieldses.org>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
 <1556201060-7947-9-git-send-email-bfields@redhat.com>
 <d26e7611f4e610bff81a16abbb88ca1c5ed70c91.camel@redhat.com>
 <20190425201413.GB9889@fieldses.org>
X-Mailer: Apple Mail (2.3273)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--Apple-Mail=_EB3E3A59-94EE-44CC-8383-078B4B992E50
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Apr 25, 2019, at 10:14 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Thu, Apr 25, 2019 at 02:04:59PM -0400, Jeff Layton wrote:
>> More bikeshedding: should we have a "states" file instead of an "opens"
>> file and print a different set of output for each stateid type?
> 
> Sure.  The format of the file could be something like
> 
> 	<stateid> open rw -- <openowner>...
> 	<stateid> lock r 0-EOF <lockowner>...
> 	<stateid> deleg r
> 
> I wonder if we could put owners on separate lines and do some
> heirarchical thing to show owner-stateid relationships?  Hm.  That's
> kind of appealing but more work.

My suggestion here would be to use YAML-formatted output rather than
space/tab separated positional fields.  That can still be made human
readable, but also machine parseable and extensible if formatted properly.

Something like the following (use https://yaml-online-parser.appspot.com/
to validate the formatting):

- <stateid>: { state: open, mode: rw, owner: <openowner> }
- <stateid>: { state: lock, mode: r, start: 0, end: EOF, owner: <openowner> }


> I was only planning to do opens for the first iteration, and I think
> extending later in separate files is slightly safer.
> 
> More trivial, but: it'd lengthen lines and make columns line up less
> often.  But if we include a lot of long variable-length fields then
> that's kinda hopeless anyway.
> 
> --b.


Cheers, Andreas






--Apple-Mail=_EB3E3A59-94EE-44CC-8383-078B4B992E50
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAlzCIzAACgkQcqXauRfM
H+DlOw//VSr+buQMPY+uIy7a+0sVuPJbaxqgSkrvlzeyVcyPRwlvYSiZ4ZyhCIYT
hH9QvT+SpWVLOQlReuRxmZJh64kTpuSuFzPNII5NF5JRcbNfmitpltylSNzLovIZ
m0fwuVGylQwNMdhltPuGpngAIzg6TkdoI14qKyQ17PV+sdWma8Zb7C+XTXdAItGM
xI9PtRlTTGs6/jYd8C3yTT03qcNoUbK1eLAbN002MiWWMIvllZ3aeXncQbTIJIr2
dcZyCTYo47iDo2lkulvKKO62IjyPw6Oh+VsfgjB6i1LJrUFqUYTJYT72YutQ+LS5
bIs9XK619RwEOClPqbtpSIXGaTuEK+Dh7rZF58cl65OzamseuxYk0YhQNHoZds/5
HgGjwLbPH5CEr9j+sc07iWjbNH1KWWckryBTYG1KLthHw40hS9WZp2HIr/6mp3PN
Z08tti2uuAndjMXZ0NoPQdF/yo0NtQ1PzI8C+VCmEcysIY+5fx6GR4VOQk96/f2E
m1m2D8ooKZ1WV/MDLX90inSNRdQFgj7bAFfDp0BVv2ywpAe5GxnsZCx97VMizwhj
h33Kvw9pznMf6yQDITypFJ98N8g8P1QqwMEAaEgLtgXAHv+nVLPn1SnGnH43DuSu
pZOpH4f+6mc7U8RxawDgiTOc06p51gxqaegRrtROu41ZiZp/hMw=
=sOWl
-----END PGP SIGNATURE-----

--Apple-Mail=_EB3E3A59-94EE-44CC-8383-078B4B992E50--

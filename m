Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:41644 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754611AbbCBPUR convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2015 10:20:17 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YSS8m-0006es-PU
	for linux-nfs@vger.kernel.org; Mon, 02 Mar 2015 10:20:16 -0500
Received: from mail-yk0-f169.google.com ([209.85.160.169])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YSS8m-00060w-Kc
	for linux-nfs@vger.kernel.org; Mon, 02 Mar 2015 10:20:16 -0500
Received: by ykbq200 with SMTP id q200so13648919ykb.6
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 07:20:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
 <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
 <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
 <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
 <20150227224029.GA8750@fieldses.org> <0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com>
From: Chris Perl <cperl@janestreet.com>
Date: Mon, 2 Mar 2015 10:19:56 -0500
Message-ID: <CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I’m in favor of staying more hand-wavy. Otherwise you will end up
> making promises you don’t intend to keep ;-)

FWIW, I'm in favor of at least some specifics.  Something stating that
the results of reading from a file while another client holds it open
for write are undefined (point 3 of what was already proposed).

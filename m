Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sandeen.net ([63.231.237.45]:36515 "EHLO sandeen.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620AbbAWFfi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 00:35:38 -0500
Message-ID: <54C1DDA8.5040103@sandeen.net>
Date: Thu, 22 Jan 2015 23:35:36 -0600
From: Eric Sandeen <sandeen@sandeen.net>
MIME-Version: 1.0
To: Steve French <smfrench@gmail.com>, fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: xfstest generic/299
References: <CAH2r5mvSUc0-Z1Kn3NfowUzH1Jw4x_8UF46+uXKBPshuFkb1dw@mail.gmail.com>
In-Reply-To: <CAH2r5mvSUc0-Z1Kn3NfowUzH1Jw4x_8UF46+uXKBPshuFkb1dw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/22/15 11:23 PM, Steve French wrote:
> Noticed test generic/299 failing over NFS (v4.1 dialect) with the error
> 
> "[not run] /usr/bin/fio too old"
> 
> fio-2.1.11 version (which is what is installed on current Ubuntu) is
> presumably not too old

Well, 2.1.11 was released 16-Jul-2014

fio is up to 2.2.5 now, so it sure could be.

The test sets up a config file, and tries to run fio against it;
if it fails, it's deemed "too old"

And _require_fio dumps to $seqres.full,

        $FIO_PROG --warnings-fatal --showcmd $job >> $seqres.full 2>&1
        [ $? -eq 0 ] || _notrun "$FIO_PROG too old, see $seqres.full"

so what does 299.full look like?

-Eric

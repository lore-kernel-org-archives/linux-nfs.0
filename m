Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:22443 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752292AbbKBQwg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 11:52:36 -0500
From: Andrew W Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org, jlayton@poochiereds.net
Subject: Re: Update and questions.
References: <m21tc8l5as.fsf@discipline.rit.edu>
Date: Mon, 02 Nov 2015 11:52:35 -0500
In-Reply-To: <m21tc8l5as.fsf@discipline.rit.edu> (Andrew W. Elble's message of
	"Mon, 02 Nov 2015 11:44:27 -0500")
Message-ID: <m2si4ojqcs.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> This one has four:
>
> file fh: 6ecdd5f8 R:4 F:4 FP:ffff88083e2974a0 I:ffff881f6c9349d0
> D:ffff883f4ad1e780 /home/<stuff>
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000f1620800/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000f0620800/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000c64c0800/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000c74c0800/1

For clarity, these still are around even after killing any processes that
would have this file opened - and unmounting the filesystem from the client.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912

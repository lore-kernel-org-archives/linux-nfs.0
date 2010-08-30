From: Jens Axboe <jaxboe@fusionio.com>
Subject: Re: [PATCH] Fix lost wake-up shutting down writeback thread
Date: Mon, 30 Aug 2010 13:56:20 +0200
Message-ID: <4C7B9C64.7010804@fusionio.com>
References: <20100825023425.GA24591@fieldses.org> <1282889595.2763.14.camel@localhost> <1282901780.12016.54.camel@localhost> <4C77B873.8010306@netapp.com> <20100827160912.GA18790@fieldses.org> <10B234E0D3A1CA469E00963BF106CA392D0DB78354@NOK-EUMSG-02.mgdnok.nokia.com> <20100827210626.GB27694@fieldses.org> <20100827212842.GC27694@fieldses.org>,<4C78B1C8.10909@fusionio.com> <10B234E0D3A1CA469E00963BF106CA392D0DB78357@NOK-EUMSG-02.mgdnok.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
	"bjschuma@netapp.com" <bjschuma@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"trond@netapp.com" <trond@netapp.com>, "hch@lst.de" <hch@lst.de>
To: "Artem.Bityutskiy@nokia.com" <Artem.Bityutskiy@nokia.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 0122700014.0.fullrate.dk ([95.166.99.235]:39419 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026Ab0H3L4U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 07:56:20 -0400
In-Reply-To: <10B234E0D3A1CA469E00963BF106CA392D0DB78357-xJW1crHCIS+8kqYwC468Frtp2NbXvJi8gfoxzgwHRXE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-08-29 14:21, Artem.Bityutskiy@nokia.com wrote:
>> Thanks Bruce, I've applied this as well.
> 
> Thanks for picking up! But you could also add my Acked tag, just for the record.

Thanks, added.

-- 
Jens Axboe


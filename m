Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:51411 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758522Ab0EYOCh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 10:02:37 -0400
Date: Tue, 25 May 2010 16:02:40 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, salvet@ics.muni.cz
Subject: Re: Deadlock in NFSv4 in all kernels
Message-ID: <20100525140240.GG9731@ics.muni.cz>
References: <20100507153920.GP28167@ics.muni.cz>
 <AANLkTimsQTYWndbQo2nU01pcJfTRSZlPCMEY8m-CnksM@mail.gmail.com>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <AANLkTimsQTYWndbQo2nU01pcJfTRSZlPCMEY8m-CnksM@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 09:45:32AM -0400, William A. (Andy) Adamson wrote:
> Not get into the problem in the first place: this means
> 
> 1) determine a 'lead time' where the NFS client declares a context
> expired even though it really as 'lead time' until it actually
> expires.
> 
> 2) flush all writes on any contex that will expire within the lead
> time which needs to be long enough for flushes to take place.

I think you cannot give any guarantees that the flush happens on time. There
can be server overload, network overload, anything and you are out of luck. 

-- 
Luká¹ Hejtmánek

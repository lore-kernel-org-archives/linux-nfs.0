From: Denis Zaitsev <zzz@anda.ru>
Subject: Re: [BUG] Onboard Ethernet Pro 100 on a SMP box: a very strange errors
Date: Wed, 26 Jan 2005 07:37:49 +0500
Message-ID: <20050126073749.A2142@natasha.ward.six>
References: <20050122014646.A1038@natasha.ward.six> <200501252319.11304.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-net-owner@vger.kernel.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200501252319.11304.vda@port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Tue, Jan 25, 2005 at 11:19:11PM +0200
Sender: linux-net-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jan 25, 2005 at 11:19:11PM +0200, Denis Vlasenko wrote:
> 
> Something corrupts packets. It can be sending NIC, switch in the middle,
> or receiving NIC.

Changing the receiving card closes the question.  Doesn't it matter?

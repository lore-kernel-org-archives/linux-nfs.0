From: Chris Leech <chris.leech@gmail.com>
Subject: Re: [BUG] Onboard Ethernet Pro 100 on a SMP box: a very strange errors
Date: Wed, 26 Jan 2005 11:11:25 -0800
Message-ID: <41b516cb0501261111e5edbc5@mail.gmail.com>
References: <20050122014646.A1038@natasha.ward.six>
	 <200501252319.11304.vda@port.imtp.ilyichevsk.odessa.ua>
	 <20050126073749.A2142@natasha.ward.six>
Reply-To: Chris Leech <chris.leech@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	nfs@lists.sourceforge.net
In-Reply-To: <20050126073749.A2142@natasha.ward.six>
Sender: linux-net-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 26 Jan 2005 07:37:49 +0500, Denis Zaitsev <zzz@anda.ru> wrote:
> On Tue, Jan 25, 2005 at 11:19:11PM +0200, Denis Vlasenko wrote:
> >
> > Something corrupts packets. It can be sending NIC, switch in the middle,
> > or receiving NIC.
> 
> Changing the receiving card closes the question.  Doesn't it matter?

Take a look at this technical advisory for the STL2 board, I'm fairly
sure this is your issue.
http://support.intel.com/support/motherboards/server/sb/CS-010790.htm

IP fragmented packets as part of an NFS file transfer are improperly
being identified as TCO management packets and are being routed to the
BMC.  The fix is to upgrade the BMC firmware.

Updated BMC firmware and BIOS images for this board are available at
http://support.intel.com/support/motherboards/server/STL2/sb/CS-007118.htm

- Chris

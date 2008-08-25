From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Mon, 25 Aug 2008 15:15:01 -0500
Message-ID: <48B312C5.9010702@opengridcomputing.com>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>	 <1219087258.7192.19.camel@localhost>	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>	 <1219428489.6919.21.camel@localhost>	 <1219428818.27921.43.camel@localhost.localdomain>	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>	 <1219435207.27921.51.camel@localhost.localdomain>	 <1219440202.9097.14.camel@localhost>	 <1219441041.27921.57.camel@localhost.localdomain>	 <1219442213.9097.25.camel@localhost>	 <1219603981.27921.145.camel@localhost.localdomain>	 <1219605422.14389.2.camel@localhost>  <1219605596.14389.5.camel@localhost>	 <1219615789.27921.152.camel@localhost.localdomain>	 <1219616136.14389.12.camel@localhost>	 <48B2D7F8.5020206@opengridcomputing.com> <1219683253.7665.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:47514 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752961AbYHYUPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 16:15:03 -0400
In-Reply-To: <1219683253.7665.13.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2008-08-25 at 11:04 -0500, Tom Tucker wrote:
>> I don't think it should matter how long the connection stays in FIN WAIT,
>> the client should reconnect anyway.
> 
> Which would break the replay cache, since we can't reconnect using the
> same port.
> 
>> Since the client seems to be the variable, I would think it might be an
>> issue with the client reconnect logic?
> 
> No.
> 

Yeah, you're right. I got confused about which host was stuck in FIN_WAIT2.
It's the client as you pointed out earlier.

Thanks,
Tom


> Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


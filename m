From: "John Ronciak" <john.ronciak@gmail.com>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 22 Aug 2008 14:15:36 -0700
Message-ID: <56a8daef0808221415y111a8024w117e6aa8526eba7@mail.gmail.com>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	 <1219435207.27921.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Grant Coady" <gcoady.lk@gmail.com>, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, linux-nfs@vger.kernel.org,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>,
	"Bruce Allan" <bruce.w.allan@intel.com>,
	"PJ Waskiewicz" <peter.p.waskiewicz.jr@intel.com>,
	"John Ronciak" <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: "Ian Campbell" <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:12772 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbYHVVPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 17:15:38 -0400
Received: by nf-out-0910.google.com with SMTP id d3so297163nfc.21
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2008 14:15:37 -0700 (PDT)
In-Reply-To: <1219435207.27921.51.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 22, 2008 at 1:00 PM, Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org> wrote:

> So far as I can tell, yes. I can login via ssh so long as the user
> doesn't have NFS $HOME, I haven't tried much else and the box isn't
> locked up at the moment, I'd bet it's fine though.
Then it's highly unlikely that the NIC/driver is causing your problem.
 We'll continue to monitor this thread waiting for any info that this
is somehow NIC/driver related.

Good luck.



-- 
Cheers,
John

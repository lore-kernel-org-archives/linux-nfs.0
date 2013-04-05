Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:34161 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161612Ab3DENL0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 09:11:26 -0400
Date: Fri, 5 Apr 2013 15:11:13 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 monitoring tool
Message-ID: <20130405131113.GD25618@ics.muni.cz>
References: <20121015163851.GO5412@ics.muni.cz>
 <20121015174305.GA26840@fieldses.org>
 <20130405124822.GB25618@ics.muni.cz>
 <20130405125833.GA1194@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20130405125833.GA1194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 05, 2013 at 08:58:33AM -0400, J. Bruce Fields wrote:
> Sure.  If you have a detailed description of the statistics that you're
> gathering (and/or the systemtap scripts), that could help make sure we
> capture what you need.

this is what we are collecting:
https://www.dropbox.com/s/p88kvh547t5udpv/nfsdacc-fullpath.stp

-- 
Luká¹ Hejtmánek

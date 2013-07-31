Return-Path: linux-nfs-owner@vger.kernel.org
Received: from srv2.trombetti.net ([65.254.53.252]:1101 "EHLO
	srv2.trombetti.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759199Ab3GaIfU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jul 2013 04:35:20 -0400
Message-ID: <51F8CC45.3000409@shiftmail.org>
Date: Wed, 31 Jul 2013 10:35:17 +0200
From: Spelic <spelic@shiftmail.org>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Nfs4 idmapping: new kernel sends numeric
References: <51F1B0FF.4010602@shiftmail.org> <20130726154110.GD30651@fieldses.org>
In-Reply-To: <20130726154110.GD30651@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26/07/2013 17:41, J. Bruce Fields wrote:
> You can work around this by turning off the new server behavior by 
> setting the nfsd.nfs4_disable_idmapping module parameter to 0. --b.
>

Thanks Bruce, it works great!



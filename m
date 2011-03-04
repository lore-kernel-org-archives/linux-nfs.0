Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab1CDGK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2011 01:10:28 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p246ASE6007953
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 4 Mar 2011 01:10:28 -0500
Date: Fri, 04 Mar 2011 15:10:26 +0900 (JST)
Message-Id: <20110304.151026.946624858093159104.yamato@redhat.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Read /etc/exports.d/*.export as extra export files
From: Masatake YAMATO <yamato@redhat.com>
In-Reply-To: <4D6FFF80.6030102@RedHat.com>
References: <20110217.215900.388120588347145930.yamato@redhat.com>
	<20110303.230122.1012453714437438591.yamato@redhat.com>
	<4D6FFF80.6030102@RedHat.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

thank you for replying.

> On 03/03/2011 09:01 AM, Masatake YAMATO wrote:
>> No comment?
> Sorry about that... I was traveling for the couple weeks... 
> 
> Would you happen to have an example script on how 
> this new feature would be used? I just want to run 
> some quick tests...
> 
> tia,
> 
> steved.

Could you try following one?

# cd /tmp
# mkdir /tmp/alpha
# mkdir /tmp/beta
# mkdir /etc/exports.d
# mkdir /etc/exports.d
# echo '/tmp/alpha *(ro)' > /etc/exports.d/alpha.export
# echo '/tmp/beta *(ro)'  > /etc/exports.d/beta.export
# /etc/init.d nfs restart

After above setting up, when you do `exportfs', following lines 
may be included in the output:

    /tmp/alpha	 <world>
    /tmp/beta        <world>


Masatake YAMATO

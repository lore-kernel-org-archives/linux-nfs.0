Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vergina.eng.auth.gr ([155.207.18.1]:54810 "EHLO
	vergina.eng.auth.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248Ab0ITJyv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 05:54:51 -0400
Message-ID: <4C972F4D.3050409@eng.auth.gr>
Date: Mon, 20 Sep 2010 12:54:21 +0300
From: George Mamalakis <mamalos@eng.auth.gr>
To: Jeff Layton <jlayton@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsv3 gssapi client?
References: <4C938F3B.4030604@eng.auth.gr>	<20100917174328.GC25515@fieldses.org> <20100917143506.0b85a04b@tlielax.poochiereds.net>
In-Reply-To: <20100917143506.0b85a04b@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hi Jeff, and thanx for your answer,
>> 111 is ECONNREFUSED.  I'm not sure why that's failing.  (Should failure
>> to register lockd fail the whole mount?  I thought it would at worst
>> result in ENOLCK on lock requests?) Do you get better results if you
>> mount with nolock?
>>
> Firewalling issues maybe?
>
The fbsd box runs no firewall whatsoever, and nvsv3 mounts work just 
fine if sec=sys is given in the mount command instead of sec=krb5(ip). 
On the linux box I haven't setup any iptables whatsoever. My 
/etc/hosts.allow on the linuxbox reads:
[root@linuxclient ~]# cat /etc/hosts.allow
#
# /etc/hosts.allow
#
ALL:ALL


So I guess that there is no problem from this side too.

Thanx again,

mamalos


PS. Sorry I haven't answered to your question in my previous email, I 
saw your email after sending the previous answer.

-- 
George Mamalakis

IT Officer
Electrical and Computer Engineer (Aristotle Un. of Thessaloniki),
MSc (Imperial College of London)

Department of Electrical and Computer Engineering
Faculty of Engineering
Aristotle University of Thessaloniki

phone number : +30 (2310) 994379


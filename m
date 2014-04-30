Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753180AbaD3RYb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 13:24:31 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s3UHOU8l027933
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2014 13:24:31 -0400
Message-ID: <536131CD.5090204@RedHat.com>
Date: Wed, 30 Apr 2014 13:24:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Shijoe George <spanjikk@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [libnfsidmapd PATCH] nss: use strrchr() instead of strchr() to
 get the last occurrence of "@"
References: <533AE1EA.4030103@redhat.com>
In-Reply-To: <533AE1EA.4030103@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/01/2014 11:57 AM, Shijoe George wrote:
> Issues with AD/IPA Trust works & how SSSD deals with AD users.
> 
> Lets say we have a IPA domain linux.example.com & AD domain win.example.com, We setup IPA/AD trust so that Windows domain users can login into Linux, When we setup AD Trust with IPA, AD users login as username@AD_REALM, With our example above, username will be "user@win.example.com" Without @win.example.com that user will be searched only in IPA domain not in AD domain. That is the reason @DOMAIN part is important in SSSD when dealing with IPA-AD trust.
> 
> With current behaviour the client-side code is stripping the domain off based on the location of the first "@" character in the value returned by the server. This results in UID/GID mappings failing and resulting in ownership on the clients as "nobody".
> 
> With the provided patch, we can accept fully qualified usernames.
Committed...

steved.


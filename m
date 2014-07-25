Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e38.co.us.ibm.com ([32.97.110.159]:40184 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbaGYQzC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 12:55:02 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Fri, 25 Jul 2014 10:55:01 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2D97519D8039
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 10:54:48 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6PGrh7I38863082
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 18:53:43 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6PGswus030129
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 10:54:58 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id s6PGsw4a030094
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 10:54:58 -0600
In-Reply-To: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
References: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: Patch For Making Readdir_plus configurable
Message-ID: <OFEE6E32F0.CC4EA662-ON87257D20.005CDC46-86257D20.005CEC4F@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Fri, 25 Jul 2014 11:54:57 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a client side option "nordirplus" which can be used to force the 
client to use READDIR


Christopher Vogan
NFS Development & Test


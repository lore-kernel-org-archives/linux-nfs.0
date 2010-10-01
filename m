Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37693 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843Ab0JAER5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 00:17:57 -0400
In-Reply-To: <4CA455C4.4030705@panasas.com>
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de> <4CA455C4.4030705@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org
Subject: pNFS DS session
Message-ID: <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com>
From: Marc Eshel <eshel@almaden.ibm.com>
Date: Thu, 30 Sep 2010 21:17:46 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Benny,

Running connectathon I see that some times the clients decides to destroy 
the session with the DS. The test continue and the session is 
re-established. It looks like layout return reduces the hold on device 
info the reduces the hold on the client struct which decide to destroy the 
session. Is that a known problem?

Thanks, Marc.

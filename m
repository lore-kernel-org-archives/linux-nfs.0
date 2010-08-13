From: Risto Bell <reb-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>
Subject: Re: NFS and file locking for use with sqllite
Date: Fri, 13 Aug 2010 15:09:39 -0700
Message-ID: <4C65C2A3.40404@cypress.com>
References: <AANLkTik_gAeTWhD_=zSUrqh2eYir=q4bK4cJ6UdGQ11M@mail.gmail.com> <0C88B758-1DE8-4CFB-9546-A30104009A12@oracle.com> <AANLkTimqTvgyvvjP2R12wsdpZRs10T+YAtUGw7u6pxWZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.cypress.com ([157.95.67.5]:52108 "EHLO ns2.cypress.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755055Ab0HMWWG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 18:22:06 -0400
Received: from corpmail.cypress.com (corpmail [157.95.1.2])
	by ns2.cypress.com (8.12.10/8.12.10) with ESMTP id o7DM9l0n014771
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 15:09:47 -0700 (PDT)
Received: from cobweb.mis.cypress.com (cobweb.mis.cypress.com [172.16.2.5])
	by corpmail.cypress.com (8.12.10/8.12.10) with ESMTP id o7DM9foX000909
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 15:09:41 -0700 (PDT)
Received: from meson.design.cypress.com (meson.design.cypress.com [172.17.2.36])
	by cobweb.mis.cypress.com (8.12.11/8.12.11) with ESMTP id o7DM9egb002729
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 15:09:40 -0700 (PDT)
Received: from lucas.design.cypress.com (lucas [172.17.14.37])
	by meson.design.cypress.com (8.9.3+Sun/8.9.3) with ESMTP id PAA06486
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 15:09:39 -0700 (PDT)
Received: from lucas.design.cypress.com (localhost [127.0.0.1])
	by lucas.design.cypress.com (8.13.8/8.13.8) with ESMTP id o7DM9dXM029512
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 15:09:39 -0700
In-Reply-To: <AANLkTimqTvgyvvjP2R12wsdpZRs10T+YAtUGw7u6pxWZ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 From client, how to remotely query server for list of locks held?
Helpful if debugging lock recovery failures.

---------------------------------------------------------------
This message and any attachments may contain Cypress (or its
subsidiaries) confidential information. If it has been received
in error, please advise the sender and immediately delete this
message.
---------------------------------------------------------------


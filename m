Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout4.samsung.com ([203.254.224.34]:46272 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756666Ab2EJG7j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2012 02:59:39 -0400
Received: from epcpsbge3.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M3S00F94OPJE2G0@mailout4.samsung.com> for
 linux-nfs@vger.kernel.org; Thu, 10 May 2012 15:59:31 +0900 (KST)
Date: Thu, 10 May 2012 06:59:31 +0000 (GMT)
From: AMIT SAHRAWAT <a.sahrawat@samsung.com>
Subject: =?windows-1252?Q?[Problem]NFS_Server_=96_Umount_results_in_Device_Busy.?=
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org,
        "namjae.jeon@samsung.com" <namjae.jeon@samsung.com>
Reply-to: a.sahrawat@samsung.com
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
MIME-version: 1.0
Message-id: <32336989.330131336633170527.JavaMail.weblogic@epml01>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TGludXggS2VybmVsOiAyLjYuMzUuMTQNCiANCldlIGFyZSB1c2luZyBORlMgZm9yIGRhdGEgdHJh
bnNmZXIgZnJvbSBvbmUgdGFyZ2V0IHRvIGFub3RoZXIgdGFyZ2V0Lg0KT24gU2VydmVyIHdlIGFy
ZSB1c2luZyAzIG1vdW50IHBvaW50cyCWIHRvIGJlIHVzZWQgYnkgYXBwbGljYXRpb24uIEFuZCB0
aGV5IGFyZSBtZW50aW9uZWQgaW4gL2V0Yy9leHBvcnRzDQogDQpXaGVuIGluaXRpYWxseSBqdXN0
IE5GUyBTZXJ2ZXIgaXMgc3RhcnRlZCAtV2UgY2FuIG1vdW50IGFuZCBzYWZlbHkgdW4tbW91bnQg
dGhlIE5GUyBtb3VudCBwb2ludC4NCk5vdywgd2hlbiBORlMgY2xpZW50IGlzIHN0YXJ0ZWQgYW5k
IHdlIG1vdW50IGF0IHRoZSBjbGllbnQuIFdpdGhvdXQgZG9pbmcgYW55IElPIJYgaWYgd2UgZG8g
dW4tbW91bnQgYXQgdGhlIE5GUyBDbGllbnQglml0IHVuLW1vdW50cyBzYWZlbHkuDQpCdXQgliB3
aGVuIHRyaWVkIHRvIHVuLW1vdW50IHRoZSBkZXZpY2UgYXQgdGhlIE5GUyBzZXJ2ZXIgliBpdCBy
ZXN1bHRzIGluIGVycm9yIJNEZXZpY2UgQnVzeZQNCpN1bW91bnQ6IGNhbid0IHVtb3VudCAvbW50
OiBEZXZpY2Ugb3IgcmVzb3VyY2UgYnVzeZQNCiANCk5vdyAsIGluIG9yZGVyIHRvIHVtb3VudCB0
aGUgZGV2aWNlIC0gIHdlIGhhdmUgdG8ga2lsbCB0aGUgcHJvY2VzcyCRbmZzZJIgliBhbmQgdGhl
biBpdCB1bi1tb3VudHMgZWFzaWx5Lg0KIA0KQXMgcGVyIG91ciB1bmRlcnN0YW5kaW5nIJYgaXQg
c2hvdWxkIG5vdCBiZSBhbiBpc3N1ZSB3aXRoIHRoZSB1bi1tb3VudCB3aGVuIGl0IGlzIG5vdCBi
ZWluZyB1c2VkIGFuZCBhbHNvIHRoZXJlIHNob3VsZCBiZSBubyBkZXBlbmRlbmN5IHRvIGtpbGwg
kW5mc2SSIHRvIHVuLW1vdW50IHRoZSBkZXZpY2UuDQogDQpJdCBsZWFkcyB0byBwcm9ibGVtIG9m
IGtpbGxpbmcgkW5mc2SSIGFuZCByZXN0YXJ0aW5nIGl0IJYgdG8gbWFrZSBvdGhlciBtb3VudCBw
b2ludHMgd29yayB3aXRob3V0IGlzc3VlLg0KIA0KSXMgdGhlcmUgYW55IG1ldGhvZCB0byB1bi1t
b3VudCB0aGUgZGV2aWNlIHdpdGhvdXQgZ2V0dGluZyB0aGlzIJFCVVNZkiBlcnJvcj8gT3IgY2Fu
IHdlIGtpbGwgb25seSBuZnNkIHNlcnZpY2Ugd2hpY2ggd2FzIHVzaW5nIHRoYXQgbW91bnQgcG9p
bnQ/DQpQbGVhc2Ugc2hhcmUgeW91ciBpbnB1dCBvbiB0aGUgc29sdXRpb24gdG8gdGhlIGFib3Zl
IHByb2JsZW0uIElzIHRoaXMgZXhwZWN0ZWQgYmVoYXZpb3I/DQogDQpUaGFua3MgJiBSZWdhcmRz
LA0KQW1pdCBTYWhyYXdhdA==



Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34773 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425268AbcBRL3P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 06:29:15 -0500
Received: by mail-wm0-f52.google.com with SMTP id b205so20423220wmb.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Feb 2016 03:29:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
From: Martin Houry <martinhoury@gmail.com>
Date: Thu, 18 Feb 2016 12:28:54 +0100
Message-ID: <CAEUt8VKJv-8UBrNc48=mbzvT==FeV1DQEPxwDayoVujuZSh-nQ@mail.gmail.com>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, if we have multi host addresses can we specify the client
interfaces adresses?
In other words is it possible for the client to choose the interface
which'll be used to send the data?

An another point is what is the best way to delete an existing
connection of an existing session?

Martin

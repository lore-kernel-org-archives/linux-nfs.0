Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:35344 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755483AbbDXPeL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 11:34:11 -0400
Received: by qcbii10 with SMTP id ii10so27645885qcb.2
        for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2015 08:34:10 -0700 (PDT)
From: Gregory Boyce <gregory.boyce@gmail.com>
In-Reply-To: <553A42B4.5010101@RedHat.com>
References: <alpine.DEB.2.10.1504201432530.5987@valhalla.home> <553A42B4.5010101@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: nfs-utils: Allow users to disable mount option rewriting via norewriteopts mount option
Date: Fri, 24 Apr 2015 11:34:07 -0400
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-ID: <5D733909-FD0F-437E-A97A-4CABBD876832@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On April 24, 2015 9:18:44 AM EDT, Steve Dickson <SteveD@redhat.com> wrote:
>Hello,
>
>On 04/20/2015 02:34 PM, Gregory Boyce wrote:
>> Allow users to disable mount option rewriting via norewriteopts mount
>option.
>> This was required in our case in order to allow mounting a filer 
>> which inappropriately responded via the wrong interface.
>Why are we adding a mount option to fix a broken server??
>
>steved.
>
>

Sometimes you only control the client, and it's useful to have the option to interoperate.

--
Greg

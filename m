Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:35328 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbbJMPND (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 11:13:03 -0400
Received: by obbzf10 with SMTP id zf10so16078470obb.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 08:13:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFNor0HmY5xMM7EVfGtec8U2iUVk8942xzC6sAP4Yn4sA@mail.gmail.com>
References: <20151013122128.GD10632@dot.dmz.freshdot.net>
	<CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
	<20151013143445.GE10632@dot.dmz.freshdot.net>
	<CAN-5tyFNor0HmY5xMM7EVfGtec8U2iUVk8942xzC6sAP4Yn4sA@mail.gmail.com>
Date: Tue, 13 Oct 2015 11:13:02 -0400
Message-ID: <CAHQdGtTF5OiCoQ++Tqk=PpwWYXaL9rG38DaeGUqcezfEYOudSg@mail.gmail.com>
Subject: Re: CAP(abilities) and NFS mounted storage
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 11:02 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Tue, Oct 13, 2015 at 10:34 AM, Sander Smeenk <ssmeenk@freshdot.net> wrote:
>> Quoting Trond Myklebust (trond.myklebust@primarydata.com):
>>
>>> > I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
>>> > not enough. I'd very much like to hear if it is possible for this to
>>> > work on NFS like it does on local storage.
>>> This will not work on NFS. The server, which enforces permissions, has
>>> no way to know what capabilities your process has on the client.
>>
>> Thanks. I feared this answer. But i understand that the NFS-server cant
>> know if the process on the NFS-client has CAP_DAC_READ_SEARCH
>> capabilities set.
>>
>> Would setfsuid() help anything in this case? Or is it just a big no-go?

setfsuid() would allow you to set a user up with root privileges on
the fs. That's better than giving overall root privileges, but is
still a risk, since a user could use it to overwrite /etc/passwd etc.

> Are you looking for something like labeled NFS that supports
> capabilities? I think Redhat7 has SElinux labeled NFS support.
>

The labeled NFS implementation is client enforced and confers no extra
privileges on the server. Plus (please correct me if I'm wrong), I
believe NetApp has yet to announce support for labeled NFS in OnTAP.

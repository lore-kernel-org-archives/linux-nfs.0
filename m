Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35890 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbaIYROo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 13:14:44 -0400
Received: by mail-lb0-f177.google.com with SMTP id z12so13039267lbi.36
        for <linux-nfs@vger.kernel.org>; Thu, 25 Sep 2014 10:14:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140925183034.432731eb@harpe.intellique.com>
References: <5424156C.8080602@eas.gatech.edu>
	<20140925183034.432731eb@harpe.intellique.com>
Date: Thu, 25 Sep 2014 13:14:42 -0400
Message-ID: <CAHEKYV6mfLjJDBcXzoHsckehtz0w7WW27hykS3wk4KzA9jpU0g@mail.gmail.com>
Subject: Re: NFS Share To OS X
From: Mauricio Tavares <raubvogel@gmail.com>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: MJ Jenkins <mack.jenkins@eas.gatech.edu>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2014 at 12:30 PM, Emmanuel Florac
<eflorac@intellique.com> wrote:
> Le Thu, 25 Sep 2014 09:15:24 -0400
> MJ Jenkins <mack.jenkins@eas.gatech.edu> écrivait:
>
>> The problem comes in when the user on the Mac writes files to the NFS
>> share.  On the RHEL side the files are owned by user root and group
>> nfsnobody.  Has anyone else run into this issue?  I'm not sure if the
>> issue is how I am exporting the share to the Mac, or how I have the
>> share mounted on the Mac.
>
> Without the content of your /etc/exports, it's impossible to know
> what's happening. Mac behave like regular NFS clients. Maybe you have
> "all_squash,anonuid=0,anongid=5" in your export parameter, maybe it's
> something else entirely.
>
       I really want to say you need to export the fileshare with the
"insecure" option to make the Mac happy. Unfortunately I cannot check
that right now.

> --
> ------------------------------------------------------------------------
> Emmanuel Florac     |   Direction technique
>                     |   Intellique
>                     |   <eflorac@intellique.com>
>                     |   +33 1 78 94 84 02
> ------------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

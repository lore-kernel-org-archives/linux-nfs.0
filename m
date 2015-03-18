Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbbCRQem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 12:34:42 -0400
Date: Wed, 18 Mar 2015 12:34:40 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Peng Yu <pengyu.ut@gmail.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS hang after concurrent writes
In-Reply-To: <CABrM6wkK1=Pr6ys3TxC-Xxaa9YYLT4oEvi0ZR-VOrv-61dpp3g@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1503181232120.947@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com> <alpine.OSX.2.19.9992.1503100423290.456@planck.local> <CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com> <alpine.OSX.2.19.9992.1503100735000.456@planck.local>
 <CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com> <alpine.OSX.2.19.9992.1503111012530.947@planck.local> <CABrM6wmcSE_iZ1tjdYO9716aoxprP+06UcaDL759S1ATsNjDjA@mail.gmail.com> <alpine.OSX.2.19.9992.1503181117010.947@planck.local>
 <CABrM6wnv10Yr48U_1sfWosR7Rzc3bOq2Jc2XZJfGh1qdgb+ZQg@mail.gmail.com> <alpine.OSX.2.19.9992.1503181130100.947@planck.local> <CABrM6wkK1=Pr6ys3TxC-Xxaa9YYLT4oEvi0ZR-VOrv-61dpp3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >> ~/.nfs000000160000351200000001 in the first account home, I am able to
> >> login using the first account.
>
> OK. I understand that  the content of ~/.nfs000000160000351200000001
> should be basically the same as the original ~/.bash_history which has
> been deleted in the NFS server via the second server. Right?
>
> The strange thing is:  when I try to login the first sever with a
> different login session, why the login session still hangs on this
> nonexistent ~/.bash_history. Is it that NFS remembers ~/.bash_history
> as just ~/.nfs000000160000351200000001. Unless the last program that
> uses ~/.bash_history quit, all subsequent programs trying to access
> ~/.bash_history will actually get to ~/.nfs000000160000351200000001?

No, after the file has been moved, if you open ~/.bash_history, that open
will be for a new separate file.

Return-Path: <pengyu.ut@gmail.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1503181130100.947@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503100423290.456@planck.local>
	<CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503100735000.456@planck.local>
	<CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503111012530.947@planck.local>
	<CABrM6wmcSE_iZ1tjdYO9716aoxprP+06UcaDL759S1ATsNjDjA@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503181117010.947@planck.local>
	<CABrM6wnv10Yr48U_1sfWosR7Rzc3bOq2Jc2XZJfGh1qdgb+ZQg@mail.gmail.com>
	<alpine.OSX.2.19.9992.1503181130100.947@planck.local>
Date: Wed, 18 Mar 2015 10:50:05 -0500
Message-ID: <CABrM6wkK1=Pr6ys3TxC-Xxaa9YYLT4oEvi0ZR-VOrv-61dpp3g@mail.gmail.com>
Subject: Re: NFS hang after concurrent writes
From: Peng Yu <pengyu.ut@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

>> ~/.nfs000000160000351200000001 in the first account home, I am able to
>> login using the first account.

OK. I understand that  the content of ~/.nfs000000160000351200000001
should be basically the same as the original ~/.bash_history which has
been deleted in the NFS server via the second server. Right?

The strange thing is:  when I try to login the first sever with a
different login session, why the login session still hangs on this
nonexistent ~/.bash_history. Is it that NFS remembers ~/.bash_history
as just ~/.nfs000000160000351200000001. Unless the last program that
uses ~/.bash_history quit, all subsequent programs trying to access
~/.bash_history will actually get to ~/.nfs000000160000351200000001?

>> Can anybody pinpoint the cause of the problem given the above description?
>
> That's expected behavior, see: http://nfs.sourceforge.net/#faq_d2

-- 
Regards,
Peng

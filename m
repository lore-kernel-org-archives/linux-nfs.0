From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils-1.1.6 released.
Date: Tue, 28 Apr 2009 11:05:51 -0400
Message-ID: <20090428150551.GE17891@fieldses.org>
References: <49ECB9E6.4010001@RedHat.com> <49EDFE21.2000007@arx.net> <49EF3A83.50409@RedHat.com> <20090422155427.GA8712@fieldses.org> <49F6E9B3.2090508@arx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58613 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbZD1PF6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 11:05:58 -0400
In-Reply-To: <49F6E9B3.2090508-nz9JlX+3IF8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2009 at 02:34:11PM +0300, Thanos Chatziathanassiou wrot=
e:
> O/H J. Bruce Fields =CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:
>> Might be worth looking at the network traffic to see if some change =
in
>> the client or in the mountd security negotiation hasn't caused the
>> client to start doing auth_null instead of auth_unix?
>>
>> --b.
>>  =20
> Apologies for taking so long, but I was out of the office last week.
> I'm attaching a tcpdump of mounting the directory ``/vhome'' and doin=
g a =20
> ``touch lala'' (my very own ``foo'') in said directory, which resulte=
d =20
> in access denied on the client.
> It doesn't say much to me, but then again I'm certainly no expert.

You could send us a network trace for us to look at; just

	tcpdump -s0 -wTMP

then do the mount, then ^C the tcpdump process, then send us the file
TMP.

--b.

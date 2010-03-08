From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: Re: [PATCH]rpc client can not deal with ENOSOCK, so translate it
 into ENOCONN
Date: Mon, 08 Mar 2010 09:13:04 +0800
Message-ID: <4B944F20.9080205@cn.fujitsu.com>
References: <4B91D01A.5010800@cn.fujitsu.com> <1267885392.4688.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58546 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751843Ab0CHBNW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Mar 2010 20:13:22 -0500
In-Reply-To: <1267885392.4688.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust =8E=CA=93=B9:
> On Sat, 2010-03-06 at 11:46 +0800, Bian Naimeng wrote:=20
>> If NFSv4 client send a request before connect, or the old connection=
 was broken
>> because a ETIMEOUT error catched by call_status, ->send_request will=
 return
>> ENOSOCK, but rpc layer can not deal with it, so translate it into EN=
OCONN.
>>
>> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
>>
>> ---

=2E.. snip...

>> -	if (!transport->sock)
>> +	if (!transport->sock || status =3D=3D -ENOTSOCK) {
>> +		/* Should we call xs_close() here? */
>> +		status =3D -ENOTCONN;
>>  		goto out;
>> +	}
>> =20
>>  	switch (status) {
>> -	case -ENOTSOCK:
>> -		status =3D -ENOTCONN;
>> -		/* Should we call xs_close() here? */
>> -		break;
>>  	case -EAGAIN:
>>  		status =3D xs_nospace(task);
>>  		break;
>=20
> The only case where xs_sendpages() will return ENOTSOCK is if
> transport->sock =3D=3D NULL, so the correct fix here is to just remov=
e that
> redundant test. There is no need to move the test for ENOTSOCK out of
> the switch statement.

  Yes. Thanks for your suggestion.

  Best Regards
   Bian

>=20
> Cheers
>   Trond


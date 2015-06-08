Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from extranet.sessys.com ([50.116.54.220]:60382 "EHLO
	extranet.sessys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbbFHOPa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 10:15:30 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH] rpc.nfsd: add no-ipv4 and no-ipv6 options
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Mon, 08 Jun 2015 10:15:28 -0400
From: Sean Elble <elbles@sessys.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <557597D3.8090401@gmail.com>
References: <55743EDE.7070707@gmail.com>
 <3CE6594A-508B-4BBD-9E52-CF9EDDA6274D@oracle.com>
 <557597D3.8090401@gmail.com>
Message-ID: <312511264c19c5a98cbd1062531b306e@mail.sessys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08.06.2015 09:25, Kinglong Mee wrote:
> On 6/8/2015 3:01 AM, Chuck Lever wrote:
>> Hi Kinglong-
>> 
>> On Jun 7, 2015, at 8:53 AM, Kinglong Mee <kinglongmee@gmail.com> 
>> wrote:
>> 
>>> Sean reports running rpc.nfsd with --host options without IPv6 
>>> address.
>>> rpc.nfsd prints error message, but runs correctly for IPv4.
>>> It is caused by that rpc.nfsd tries to bind IPv4 and IPv6 address 
>>> default.
>>> 
>>> rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name or 
>>> service not known
>> 
>> Why not just turn this message into a debugging message?
> 
> I think it's an important message for user, especially meeting error 
> both,
> we should not remove it.
> 
> Also, it's a useful feature of turning off ipv4 or ipv6 for some case.

Thanks for the patch Kinglong!

 From my perspective as a user/admin, I welcome the option to turn off 
either IPv4 or IPv6 selectively.  I could also see the sense in making 
it a debug level message, in that if it's not working as intended, 
you're going to inevitably put it into debug mode.  And, as it stands, I 
think more people see the message now (on account of it being displayed 
when a host cannot be resolved to both an IPv4 and IPv6 address) than 
those who would need to see the error, but that's sheer conjecture on my 
part.

In any case, the patch is much appreciated, and I believe the 
functionality is worth it, regardless of what is done with the message 
itself.

> 
> thanks,
> Kinglong Mee
> 
>> 
>>> This patch add no-ipv4 and no-ipv6 options to disable ipv4/ipv6 
>>> directly.
>>> 
>>> Reported-by: Sean Elble <elbles@sessys.com>
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>> ---
>>> support/include/nfs/nfs.h |  8 ++++++++
>>> utils/nfsd/nfsd.c         | 27 ++++++++++++++++++++++++++-
>>> utils/nfsd/nfsd.man       | 10 ++++++++++
>>> 3 files changed, 44 insertions(+), 1 deletion(-)
>>> 
>>> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
>>> index 27054e5..2be61f0 100644
>>> --- a/support/include/nfs/nfs.h
>>> +++ b/support/include/nfs/nfs.h
>>> @@ -47,19 +47,27 @@ struct nfs_fh_old {
>>> 
>>> #define NFSCTL_UDPBIT		      (1 << (17 - 1))
>>> #define NFSCTL_TCPBIT		      (1 << (18 - 1))
>>> +#define NFSCTL_INETBIT		      (1 << (19 - 1))
>>> +#define NFSCTL_INET6BIT		      (1 << (20 - 1))
>>> 
>>> #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 
>>> 1)))
>>> #define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_UDPBIT)
>>> #define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_TCPBIT)
>>> +#define NFSCTL_INETUNSET(_cltbits)    ((_cltbits) &= 
>>> ~NFSCTL_INETBIT)
>>> +#define NFSCTL_INET6UNSET(_cltbits)   ((_cltbits) &= 
>>> ~NFSCTL_INET6BIT)
>>> 
>>> #define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 
>>> 1)))
>>> #define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT)
>>> #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT)
>>> +#define NFSCTL_INETISSET(_cltbits)    ((_cltbits) & NFSCTL_INETBIT)
>>> +#define NFSCTL_INET6ISSET(_cltbits)   ((_cltbits) & NFSCTL_INET6BIT)
>>> 
>>> #define NFSCTL_VERDEFAULT (0xc)       /* versions 3 and 4 */
>>> #define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 
>>> 1)))
>>> #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
>>> #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
>>> +#define NFSCTL_INETSET(_cltbits)      ((_cltbits) |= NFSCTL_INETBIT)
>>> +#define NFSCTL_INET6SET(_cltbits)     ((_cltbits) |= 
>>> NFSCTL_INET6BIT)
>>> 
>>> #define NFSCTL_ANYPROTO(_cltbits)     ((_cltbits) & (NFSCTL_UDPBIT | 
>>> NFSCTL_TCPBIT))
>>> #define NFSCTL_ALLBITS (~0)
>>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
>>> index 201bb13..4cd1ea8 100644
>>> --- a/utils/nfsd/nfsd.c
>>> +++ b/utils/nfsd/nfsd.c
>>> @@ -42,6 +42,8 @@ static struct option longopts[] =
>>> 	{ "nfs-version", 1, 0, 'V' },
>>> 	{ "no-tcp", 0, 0, 'T' },
>>> 	{ "no-udp", 0, 0, 'U' },
>>> +	{ "no-ipv4", 0, 0, 'F'},
>>> +	{ "no-ipv6", 0, 0, 'S'},
>>> 	{ "port", 1, 0, 'P' },
>>> 	{ "port", 1, 0, 'p' },
>>> 	{ "debug", 0, 0, 'd' },
>>> @@ -135,7 +137,7 @@ main(int argc, char **argv)
>>> 	xlog_syslog(0);
>>> 	xlog_stderr(1);
>>> 
>>> -	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", 
>>> longopts, NULL)) != EOF) {
>>> +	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:FS", 
>>> longopts, NULL)) != EOF) {
>>> 		switch(c) {
>>> 		case 'd':
>>> 			xlog_config(D_ALL, 1);
>>> @@ -238,6 +240,12 @@ main(int argc, char **argv)
>>> 		case 'U':
>>> 			NFSCTL_UDPUNSET(protobits);
>>> 			break;
>>> +		case 'F':
>>> +			NFSCTL_INETUNSET(protobits);
>>> +			break;
>>> +		case 'S':
>>> +			NFSCTL_INET6UNSET(protobits);
>>> +			break;
>>> 		case 'G':
>>> 			grace = strtol(optarg, &p, 0);
>>> 			if (*p || grace <= 0) {
>>> @@ -280,6 +288,16 @@ main(int argc, char **argv)
>>> 
>>> 	nfsd_enable_protos(&proto4, &proto6);
>>> 
>>> +	if (!NFSCTL_INETISSET(protobits)) {
>>> +		NFSCTL_TCPUNSET(proto4);
>>> +		NFSCTL_UDPUNSET(proto4);
>>> +	}
>>> +
>>> +	if (!NFSCTL_INET6ISSET(protobits)) {
>>> +		NFSCTL_TCPUNSET(proto6);
>>> +		NFSCTL_UDPUNSET(proto6);
>>> +	}
>>> +
>>> 	if (!NFSCTL_TCPISSET(protobits)) {
>>> 		NFSCTL_TCPUNSET(proto4);
>>> 		NFSCTL_TCPUNSET(proto6);
>>> @@ -301,6 +319,12 @@ main(int argc, char **argv)
>>> 		exit(1);
>>> 	}
>>> 
>>> +	if (!NFSCTL_INETISSET(protobits) &&
>>> +	    !NFSCTL_INET6ISSET(protobits)) {
>>> +		xlog(L_ERROR, "no internet protocols specified");
>>> +		exit(1);
>>> +	}
>>> +
>>> 	if (NFSCTL_VERISSET(versbits, 4) &&
>>> 	    !NFSCTL_TCPISSET(proto4) &&
>>> 	    !NFSCTL_TCPISSET(proto6)) {
>>> @@ -397,6 +421,7 @@ usage(const char *prog)
>>> 		"%s [-d|--debug] [-H hostname] [-p|-P|--port port]\n"
>>> 		"     [-N|--no-nfs-version version] [-V|--nfs-version version]\n"
>>> 		"     [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=]\n"
>>> +		"     [-F|--no-ipv4] [-S|--no-ipv6]\n"
>>> 		"     [-G|--grace-time secs] [-L|--leasetime secs] nrservs\n",
>>> 		prog);
>>> 	exit(2);
>>> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
>>> index 3ba847e..795f766 100644
>>> --- a/utils/nfsd/nfsd.man
>>> +++ b/utils/nfsd/nfsd.man
>>> @@ -77,6 +77,16 @@ Disable
>>> .B rpc.nfsd
>>> from accepting UDP connections from clients.
>>> .TP
>>> +.B \-F " or " \-\-no-ipv4
>>> +Disable
>>> +.B rpc.nfsd
>>> +from accepting IPv4 connections from clients.
>>> +.TP
>>> +.B \-S " or " \-\-no-ipv6
>>> +Disable
>>> +.B rpc.nfsd
>>> +from accepting IPv6 connections from clients.
>>> +.TP
>>> .B \-V " or " \-\-nfs-version vers
>>> This option can be used to request that
>>> .B rpc.nfsd
>>> --
>>> 2.4.2
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
>>> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

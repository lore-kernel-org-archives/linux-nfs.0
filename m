From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/26] statd: Introduce common routines to handle persistent storage
Date: Sat, 17 Oct 2009 07:46:21 +0900
Message-ID: <1A62E80E-FB8C-4322-B13D-D26067D14230@oracle.com>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net> <20091013145506.2424.10505.stgit@matisse.1015granger.net> <20091016100544.25f686c4@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, chris.mason@oracle.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:33650 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbZJPWsS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2009 18:48:18 -0400
In-Reply-To: <20091016100544.25f686c4-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 16, 2009, at 11:05 PM, Jeff Layton wrote:

> On Tue, 13 Oct 2009 10:55:06 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>> +
>> +/*
>> + * Stuff a 'struct mon' with callback data, and call @func.
>> + *
>> + * Returns the count of in-core records created.
>> + */
>> +static unsigned int
>> +nsm_parse_line(const char *hostname, const time_t timestamp, char  
>> *line,
>> +		nsm_populate_t func)
>> +{
>> +	struct sockaddr_in sin = {
>> +		.sin_family	= AF_INET,
>> +	};
>> +	struct mon mon;
>> +	int count, i;
>> +	char *c;
>> +
>> +	c = strchr(line, '\n');
>> +	if (c)
>> +		*c = '\0';
>> +
>> +	count = sscanf(line, "%8x %8x %8x %8x ",
>> +			&sin.sin_addr.s_addr,
>> +			&mon.mon_id.my_id.my_prog,
>> +			&mon.mon_id.my_id.my_vers,
>> +			&mon.mon_id.my_id.my_proc);
>> +	if (count != 4)
>> +		return 0;
>> +
>> +	c = line + 36;
>> +	for (i = 0; i < SM_PRIV_SIZE; i++) {
>> +		unsigned int tmp;
>> +		if (sscanf(c, "%2x", &tmp) != 1)
>> +			return 0;
>> +		mon.priv[i] = tmp;
>> +		c += 2;
>> +	}
>> +
>
> ^^^
> I think we need some bounds checking here. There doesn't seem to be  
> any
> guarantee that the line we read in from the "db" is a particular
> length. A check to verify that before trying to convert the cookie
> would be good.

You mean the line read from the file is possibly not long enough?  I  
think sscanf(3) will bail and we'll hit the "return 0;" if it can't  
find enough bytes in the cookie.  It would be worth adding a specific  
test or two for short db lines in the nascent statd regression/unit  
test suite.

However, any new checks we want in this particular spot should  
probably be added by subsequent patches (ie after the IPv6 support  
series is committed), so we can verify that the IPv6 changes don't  
alter the existing on-disk format logic -- they only copy it to a new  
location.  No telling what kind of odd side effects other code outside  
of nfs-utils may depend on here.

>> +	c++;
>> +	mon.mon_id.mon_name = c;
>> +	while (*c && *c != ' ')
>> +		c++;
>> +	if (*c)
>> +		*c++ = '\0';
>> +	while (*c == ' ')
>> +		c++;
>> +	mon.mon_id.my_id.my_name = c;
>> +
>> +	return func(hostname, (struct sockaddr *)&sin, &mon, timestamp);
>> +}

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




Received: from mail-ed1-f43.google.com (mail-ed1-f43.google.com [209.85.208.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA4AA7489
	for <linux-nfs@vger.kernel.org>; Wed, 30 Oct 2024 02:43:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730256205; cv=none; b=ObAwXtUy0pvlpd5rjoRxhHUmDSe1d14wQjrakGl39SPqSM8+yDx0MRbusYAJ7130FxMrK5i6e2nxJQlw0xUlV929Zud5KKCUcJYVl6SuJi6itzdi33kZfDSZ646nGg5OgUCwpO2E/XEyIV/5TM6M23pZUYSLKzNUoqym1jwZN0c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730256205; c=relaxed/simple;
	bh=E0rSFjXrk+alu+C20FJkwLy80O2ju8dcS516JVqU3pk=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=p899EojI0kkMF3Ua9T6NTQmkhwHLH6G7OhyOMh5je5ZLwbZDCmhB/4zxRChazYTpRgOyC3nq28bINL0tr5BDqdZ/finVbn+CtNRFCD8KIWvpXCM7L6HwjDxKIgt3PuwHeYYOkjO4Q071Jq0k8f/TxbDTcNTfOriRm4LxltxJlaY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lxSUEpl2; arc=none smtp.client-ip=209.85.208.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lxSUEpl2"
Received: by mail-ed1-f43.google.com with SMTP id 4fb4d7f45d1cf-5c96936065dso7112308a12.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2024 19:43:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730256202; x=1730861002; darn=vger.kernel.org;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=E0rSFjXrk+alu+C20FJkwLy80O2ju8dcS516JVqU3pk=;
        b=lxSUEpl2FuhUeDfvd1SquYZoI73oYQwfZ3A1UsBAqFA6TH2taS/gWvqTd4uNwNStcq
         aGgcePbWIkQ6FxLnD02RSoYgnWC8HtEUZ++wsjlATjBX9Pc+Xd4e009+iB0NzrSCgnoj
         A5MaDawIhJSTzwp2jbZLK37KfzyXzbRhmJwUPn8TeoGhaRXkHYA4zCcP4MIZW33NENp6
         CTAkUJRY7PRkrwh5CUd+PYdpGTe7xvjvALFpJnFO4p9JDJ03z6PctOkcObhwGwM9TITQ
         mUWTfzroJmw13GPbCuv0UsR3KYYRjOiE8uRAMwK3uFkxOdgqYtMI4zeAremwBQiEXRL0
         aPPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730256202; x=1730861002;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=E0rSFjXrk+alu+C20FJkwLy80O2ju8dcS516JVqU3pk=;
        b=URneLc9JB2ay6rAeMR1i6PSiCO0wVrJ84o9mGAQ+j0gG/zt/oos5QLT6V6pYR3jnUm
         /j2cFoCfE8bEs4Gy221wkjL5kRO2jjFtF3A111KxHxPYqrnYtgWrAKf7hhTY45PMiMjf
         +tn0qDQNPssV9TLBkMJjDzm3ouLsMS4ZhANhNAWhkhx6W/x32qDIEAveeSkEqDOjJeNg
         C5Ie2a+MrpHR4oIcusYYDntglmSOqZIl0go7q5X/rdFnVB2CrAuSHuwL3IzUNg3xYVrr
         5irB/rdYZyiUY1wMiXod9xpAWqW5Kcb7j3LcKdy9Mdbg4vZmoWQ8fnPXcYznH343B/gy
         6S8w==
X-Gm-Message-State: AOJu0YwpdDILA8FEYBTC/vuwiUMH8MWcyrQLNf4I0D/HgXC20GAT+yV8
	TF9lqXKM1zP7vbhP+VUgJ3PCL1WbUSg92sSyq6Gk14egAt6O+9maZ4gLOrDYisN6dUlT3nwkNeV
	qFs92g8TFrvpP/+05MO7qv+k2h9OG4kA=
X-Google-Smtp-Source: AGHT+IFZHWH11CIcxH6H9gzfl2Una6zfmrucEk+/+hBc/LZhWN0e8AplICBWvlSCCS6gGRPpPEqE8lDKmGtk4n+BWSo=
X-Received: by 2002:a05:6402:d05:b0:5c9:6fc1:6177 with SMTP id
 4fb4d7f45d1cf-5cd54a84c8fmr934567a12.11.1730256201876; Tue, 29 Oct 2024
 19:43:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Rick Macklem <rick.macklem@gmail.com>
Date: Tue, 29 Oct 2024 19:43:12 -0700
Message-ID: <CAM5tNy4xVcJa+qrfuze5s61rO_-tXkY60gF5WHGAvzJQ=9ZXmw@mail.gmail.com>
Subject: RFC: handling (or not) VERIFY for POSIX draft ACL attributes
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Hi,

I've run into a rough patch (no pun intended;-) w.r.t. the server
side implementation of the POSIX draft ACL attribute extension.

(N)VERIFY operations need to compare attributes for "equal" and
that is not easy.

First, the current server code compares raw XDR and that will
only compare "equal" if the ACEs are in the exact same order
and all the "who" strings (which represent users and groups)
are in the exact same format.

It would be a lot of work to rewrite VERIFY so that it does not
compare raw XDR and, even then, any difference in the way
the "who" strings are expressed on-the-wire vs what is generated
from the server's current ACL (a number in a string vs user@domain
for example) would be difficult to compare.

To avoid this problem, I am considering not allowing the POSIX
draft ACLs to be used for (N)VERIFY operations in the Internet
Draft.

Does this sound reasonable?

rick
